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
import '../../../c2c_parcels/domain/entities/c2c_parcel.dart';
import '../../../c2c_parcels/presentation/cubit/c2c_parcels_list_cubit.dart';
import '../../../c2c_parcels/presentation/cubit/c2c_parcels_list_state.dart';
import '../../../c2c_parcels/presentation/utils/c2c_parcel_labels.dart';
import '../../../c2c_parcels/presentation/widgets/c2c_parcel_card.dart';
import '../../../c2c_parcels/presentation/widgets/c2c_send_parcel_card.dart';

/// The "send parcels" side of Home: the send call to action and the
/// customer's parcels still on the move. Expects a [C2cParcelsListCubit]
/// for [C2cParcelBox.sent] above it.
///
/// Reloads the list each time it's shown — the view is rebuilt on every
/// switch to it — so a parcel created meanwhile shows up. A reload keeps
/// the current list on screen until it answers.
class HomeParcelsView extends StatefulWidget {
  const HomeParcelsView({super.key});

  @override
  State<HomeParcelsView> createState() => _HomeParcelsViewState();
}

class _HomeParcelsViewState extends State<HomeParcelsView> {
  @override
  void initState() {
    super.initState();
    context.read<C2cParcelsListCubit>().load();
  }

  Future<void> _send() async {
    final C2cParcelsListCubit cubit = context.read<C2cParcelsListCubit>();
    await context.push(AppRoutes.sendParcel);
    if (!cubit.isClosed) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        C2cSendParcelCard(onSend: _send),
        SizedBox(height: AppSpacing.xxl.h),
        const _ActiveParcelsSection(),
      ],
    );
  }
}

/// A preview of the parcels that can still move; "view all" opens the
/// full sent / received list.
class _ActiveParcelsSection extends StatelessWidget {
  const _ActiveParcelsSection();

  static const int _previewCount = 3;

  Future<void> _open(BuildContext context, C2cParcelSummary parcel) async {
    final C2cParcelsListCubit cubit = context.read<C2cParcelsListCubit>();
    await context.push(AppRoutes.c2cParcelPath(parcel.id));
    // Its status may have moved on while it was open.
    if (!cubit.isClosed) await cubit.refreshParcel(parcel.id);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.homeActiveParcelsTitle,
                style: AppTextStyles.h2(color: c.textPrimary),
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.c2cParcels),
              child: Text(
                Strings.homeViewAll,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg.h),
        BlocBuilder<C2cParcelsListCubit, C2cParcelsListState>(
          builder: (BuildContext context, C2cParcelsListState state) =>
              switch (state) {
                C2cParcelsListLoading() => Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                C2cParcelsListError(:final failure) => ErrorText(
                  message: failure.c2cMessage,
                  onRetry: () => context.read<C2cParcelsListCubit>().load(),
                ),
                C2cParcelsListLoaded(:final active) when active.isEmpty =>
                  Text(
                    Strings.homeActiveParcelsEmpty,
                    style: AppTextStyles.body(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                C2cParcelsListLoaded(:final active) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (
                      int i = 0;
                      i < active.length && i < _previewCount;
                      i++
                    ) ...<Widget>[
                      if (i > 0) SizedBox(height: AppSpacing.sm.h),
                      C2cParcelCard(
                        key: ValueKey<int>(active[i].id),
                        parcel: active[i],
                        onTap: () => _open(context, active[i]),
                      ),
                    ],
                  ],
                ),
              },
        ),
      ],
    );
  }
}
