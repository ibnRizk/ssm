import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../promotions/presentation/widgets/featured_slider_widget.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'home_categories_section.dart';
import 'home_search_field.dart';
import 'home_stores_section.dart';

/// The "deliveries" side of Home: search, promotions, categories and the
/// nearby stores. Expects a [HomeCubit] and a [PromotionsCubit] above it.
class HomeOrdersView extends StatelessWidget {
  const HomeOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const HomeSearchField(),
        SizedBox(height: AppSpacing.lg.h),
        // Owns its gap below, so the layout closes up when it hides.
        FeaturedSliderWidget(bottomSpacing: AppSpacing.xl.h),
        const _HomeCatalog(),
      ],
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
