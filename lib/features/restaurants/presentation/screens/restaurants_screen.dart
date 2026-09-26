import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/load_more_footer.dart';
import '../../../catalog/presentation/widgets/store_card.dart';
import '../cubit/stores_cubit.dart';
import '../cubit/stores_state.dart';
import '../widgets/restaurant_filter_chips.dart';
import '../widgets/restaurants_header.dart';
import '../widgets/stores_search_field.dart';

/// Stores list, pushed inside the Home tab's branch — the bottom navigation
/// bar and its Scaffold live in [MainScaffold]. Expects a [StoresCubit]
/// above it (provided at the route).
class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<StoresCubit>().load(),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (ScrollUpdateNotification notification) {
            if (notification.metrics.extentAfter < _loadMoreThreshold) {
              context.read<StoresCubit>().loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            // Pull-to-refresh must work even on a short list.
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen.w,
                  AppSpacing.lg.h,
                  AppSpacing.screen.w,
                  AppSpacing.md.h,
                ),
                sliver: SliverList.list(
                  children: <Widget>[
                    BlocSelector<StoresCubit, StoresState, int?>(
                      selector: (StoresState state) =>
                          state is StoresLoaded ? state.totalSize : null,
                      builder: (BuildContext context, int? total) =>
                          RestaurantsHeader(
                            subtitle: total == null
                                ? null
                                : Strings.restaurantsSubtitle(total),
                            onBack: () => context.pop(),
                          ),
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                    StoresSearchField(
                      onSearch: (String query) =>
                          context.read<StoresCubit>().search(query),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    const RestaurantFilterChips(),
                    SizedBox(height: AppSpacing.xl.h),
                    Text(
                      Strings.restaurantsSectionTitle,
                      style: AppTextStyles.body(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen.w,
                  AppSpacing.sm.h,
                  AppSpacing.screen.w,
                  AppSpacing.xxl.h,
                ),
                sliver: const _StoresList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoresList extends StatelessWidget {
  const _StoresList();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocBuilder<StoresCubit, StoresState>(
      builder: (BuildContext context, StoresState state) => switch (state) {
        StoresLoaded(:final stores, :final query) when stores.isEmpty =>
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl.h),
              child: Text(
                query.isEmpty
                    ? Strings.homeStoresEmpty
                    : Strings.restaurantsNoSearchResults,
                style: AppTextStyles.body(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        StoresLoaded(:final stores, :final loadMore) => SliverList.separated(
          // One extra row for the load-more footer.
          itemCount: stores.length + 1,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.lg.h),
          itemBuilder: (BuildContext context, int i) => i < stores.length
              ? StoreCard(
                  store: stores[i],
                  onTap: () => context.push(
                    AppRoutes.storeDetailsPath(stores[i].id),
                    extra: stores[i],
                  ),
                )
              : LoadMoreFooter(
                  status: loadMore,
                  onRetry: () => context.read<StoresCubit>().loadMore(),
                ),
        ),
        StoresError(:final failure) => SliverToBoxAdapter(
          child: ErrorText(
            message: failure.userMessage,
            onRetry: () => context.read<StoresCubit>().load(),
          ),
        ),
        StoresInitial() || StoresLoading() => SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl.h),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      },
    );
  }
}
