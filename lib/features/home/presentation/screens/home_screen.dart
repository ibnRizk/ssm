import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../c2c_parcels/presentation/cubit/c2c_parcels_list_cubit.dart';
import '../../../promotions/presentation/cubit/promotions_cubit.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_header.dart';
import '../widgets/home_orders_view.dart';
import '../widgets/home_parcels_view.dart';
import '../widgets/home_service_toggle.dart';

/// Home tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
///
/// A toggle under the header switches between the two services, with a
/// cross-fade. The selection is local UI state, so a [ValueNotifier] holds
/// it and only the toggle and the view below rebuild on a switch.
///
/// Expects a [HomeCubit], a [PromotionsCubit] and a [C2cParcelsListCubit]
/// above it (provided at the route).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<HomeService> _service = ValueNotifier<HomeService>(
    HomeService.orders,
  );

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  /// Refreshes what the current view shows.
  Future<void> _refresh() => switch (_service.value) {
    HomeService.orders => Future.wait<void>(<Future<void>>[
      context.read<HomeCubit>().load(),
      context.read<PromotionsCubit>().load(),
    ]),
    HomeService.parcels => context.read<C2cParcelsListCubit>().load(),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          // Pull-to-refresh must work even on a short page.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen.w,
            AppSpacing.lg.h,
            AppSpacing.screen.w,
            AppSpacing.xxl.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const HomeHeader(),
              SizedBox(height: AppSpacing.lg.h),
              ValueListenableBuilder<HomeService>(
                valueListenable: _service,
                builder: (_, HomeService selected, _) => HomeServiceToggle(
                  selected: selected,
                  onChanged: (HomeService service) => _service.value = service,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              ValueListenableBuilder<HomeService>(
                valueListenable: _service,
                builder: (_, HomeService selected, _) =>
                    _ServiceView(selected: selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cross-fades between the two services' views. Each is keyed by its
/// service so [AnimatedSwitcher] sees a new child on every switch.
class _ServiceView extends StatelessWidget {
  final HomeService selected;

  const _ServiceView({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      // Top-aligned: the views differ in height, and the default centred
      // stack would make the incoming one jump during the fade.
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[...previous, ?current],
      ),
      child: switch (selected) {
        HomeService.orders => const HomeOrdersView(
          key: ValueKey<HomeService>(HomeService.orders),
        ),
        HomeService.parcels => const HomeParcelsView(
          key: ValueKey<HomeService>(HomeService.parcels),
        ),
      },
    );
  }
}
