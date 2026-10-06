import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../promotions/presentation/cubit/promotions_cubit.dart';
import '../../../promotions/presentation/widgets/featured_slider_widget.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_field.dart';
import '../widgets/home_stores_section.dart';

/// Home tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
/// Expects a [HomeCubit] and a [PromotionsCubit] above it (provided at the
/// route).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => Future.wait<void>(<Future<void>>[
          context.read<HomeCubit>().load(),
          context.read<PromotionsCubit>().load(),
        ]),
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
              const HomeSearchField(),
              SizedBox(height: AppSpacing.lg.h),
              // Owns its gap below, so the layout closes up when it hides.
              FeaturedSliderWidget(bottomSpacing: AppSpacing.xl.h),
              const _HomeCatalog(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The API-backed sections. Rebuilds only when the loading phase changes;
/// each section selects its own slice once loaded.
class _HomeCatalog extends StatelessWidget {
  const _HomeCatalog();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (HomeState previous, HomeState current) =>
          previous.runtimeType != current.runtimeType,
      builder: (BuildContext context, HomeState state) => switch (state) {
        HomeLoaded() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const HomeCategoriesSection(),
            SizedBox(height: AppSpacing.xl.h),
            const HomeStoresSection(),
          ],
        ),
        HomeError(:final failure) => ErrorText(
          message: failure.userMessage,
          onRetry: () => context.read<HomeCubit>().load(),
        ),
        HomeInitial() || HomeLoading() => Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl.h),
          child: const Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}
