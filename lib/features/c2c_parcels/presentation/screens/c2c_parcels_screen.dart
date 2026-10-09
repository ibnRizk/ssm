import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/load_more_footer.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../cubit/c2c_parcels_list_cubit.dart';
import '../cubit/c2c_parcels_list_state.dart';
import '../utils/c2c_parcel_labels.dart';
import '../widgets/c2c_parcel_card.dart';

/// The customer's door-to-door parcels: those they send and those sent to
/// them, one tab each.
///
/// Two cubits of the same type can't both be provided above the screen,
/// so it builds one per tab with [createList] and owns them — they live
/// as long as the screen, which also keeps each tab's list across tab
/// switches.
class C2cParcelsScreen extends StatefulWidget {
  final C2cParcelsListCubit Function(C2cParcelBox box) createList;

  const C2cParcelsScreen({super.key, required this.createList});

  @override
  State<C2cParcelsScreen> createState() => _C2cParcelsScreenState();
}

class _C2cParcelsScreenState extends State<C2cParcelsScreen> {
  late final List<C2cParcelsListCubit> lists;

  @override
  void initState() {
    super.initState();
    lists = <C2cParcelsListCubit>[
      for (final C2cParcelBox box in C2cParcelBox.values)
        widget.createList(box)..load(),
    ];
  }

  @override
  void dispose() {
    for (final C2cParcelsListCubit cubit in lists) {
      cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return DefaultTabController(
      length: C2cParcelBox.values.length,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: SimpleAppBar(
          title: Strings.c2cParcelsTitle,
          onBack: () => context.pop(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: c.secondary,
          onPressed: () => context.push(AppRoutes.sendParcel),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            Strings.c2cHeroButton,
            style: AppTextStyles.button(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              TabBar(
                labelColor: c.primary,
                unselectedLabelColor: c.textSecondary,
                indicatorColor: c.secondary,
                labelStyle: AppTextStyles.titleSmall(color: c.primary),
                tabs: <Widget>[
                  Tab(text: Strings.c2cParcelsTabSent),
                  Tab(text: Strings.c2cParcelsTabReceived),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    for (final C2cParcelsListCubit cubit in lists)
                      BlocProvider<C2cParcelsListCubit>.value(
                        value: cubit,
                        child: _ParcelList(box: cubit.box),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParcelList extends StatelessWidget {
  final C2cParcelBox box;

  const _ParcelList({required this.box});

  Future<void> _open(BuildContext context, C2cParcelSummary parcel) async {
    final C2cParcelsListCubit cubit = context.read<C2cParcelsListCubit>();
    await context.push(AppRoutes.c2cParcelPath(parcel.id));
    // Its status may have moved on while it was open.
    if (!cubit.isClosed) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C2cParcelsListCubit, C2cParcelsListState>(
      builder: (BuildContext context, C2cParcelsListState state) =>
          switch (state) {
            C2cParcelsListLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            C2cParcelsListError(:final failure) => ErrorText(
              message: failure.c2cMessage,
              onRetry: () => context.read<C2cParcelsListCubit>().load(),
            ),
            C2cParcelsListLoaded(:final parcels, :final loadMore) =>
              RefreshIndicator(
                onRefresh: context.read<C2cParcelsListCubit>().load,
                child: NotificationListener<ScrollNotification>(
                  // Fetch the next page a little before the end.
                  onNotification: (ScrollNotification n) {
                    if (n.metrics.extentAfter < 300) {
                      context.read<C2cParcelsListCubit>().loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screen.w,
                      AppSpacing.md.h,
                      AppSpacing.screen.w,
                      // Room for the floating button.
                      96.h,
                    ),
                    itemCount: parcels.isEmpty ? 1 : parcels.length + 1,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: AppSpacing.sm.h),
                    itemBuilder: (BuildContext context, int index) {
                      if (parcels.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xxl.h),
                          child: NoDataFound(
                            text: box == C2cParcelBox.sent
                                ? Strings.c2cParcelsEmptySent
                                : Strings.c2cParcelsEmptyReceived,
                          ),
                        );
                      }
                      if (index == parcels.length) {
                        return LoadMoreFooter(
                          status: loadMore,
                          onRetry: context.read<C2cParcelsListCubit>().loadMore,
                        );
                      }
                      final C2cParcelSummary parcel = parcels[index];
                      return C2cParcelCard(
                        key: ValueKey<int>(parcel.id),
                        parcel: parcel,
                        onTap: () => _open(context, parcel),
                      );
                    },
                  ),
                ),
              ),
          },
    );
  }
}
