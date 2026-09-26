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
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/widgets/cart_notice_listener.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/presentation/utils/store_labels.dart';
import '../cubit/store_details_cubit.dart';
import '../cubit/store_details_state.dart';
import '../widgets/load_more_footer.dart';
import '../widgets/restaurant_cart_bar.dart';
import '../widgets/restaurant_details_header.dart';
import '../widgets/restaurant_info_card.dart';
import '../widgets/restaurant_product_card.dart';

/// Full store-details screen — unlike the tab bodies (Home, Parcels,
/// Restaurants list), this owns its own [Scaffold]: it's pushed as a
/// top-level route outside [MainScaffold]'s shell, so the bottom navigation
/// bar never shows here (see the "no bottom nav on inner screens" rule).
///
/// [StoreDetailsCubit] and [CartCubit] are provided by the route in
/// `AppRoutes`.
class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key});

  static const double _cardOverlap = 56;

  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: CartNoticeListener(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              BlocSelector<StoreDetailsCubit, StoreDetailsState, Store?>(
                selector: (StoreDetailsState state) => state.store,
                builder: (BuildContext context, Store? store) => Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    RestaurantDetailsHeader(
                      storeName: store?.name ?? '',
                      storeSubtitle: store?.subtitle ?? '',
                      onBack: () => context.pop(),
                    ),
                    if (store != null)
                      Positioned(
                        left: AppSpacing.screen.w,
                        right: AppSpacing.screen.w,
                        bottom: -_cardOverlap.h,
                        child: RestaurantInfoCard(store: store),
                      ),
                  ],
                ),
              ),
              SizedBox(height: _cardOverlap.h + AppSpacing.lg.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<StoreDetailsCubit>().load(),
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (ScrollUpdateNotification notification) {
                      if (notification.metrics.extentAfter <
                          _loadMoreThreshold) {
                        context.read<StoreDetailsCubit>().loadMore();
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.screen.w,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              Strings.storeDetailsSectionTitle,
                              style: AppTextStyles.h2(color: c.textPrimary),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.screen.w,
                            AppSpacing.md.h,
                            AppSpacing.screen.w,
                            AppSpacing.xxl.h,
                          ),
                          sliver: const _ItemsList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RestaurantCartBar(
        // Hand the *same* cubit instance to the Cart route via `extra` — a
        // fresh `BlocProvider(create: ...)` there would resolve a brand-new
        // instance from get_it's factory and the cart would appear empty.
        onViewCart: () =>
            context.push(AppRoutes.cart, extra: context.read<CartCubit>()),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocBuilder<StoreDetailsCubit, StoreDetailsState>(
      builder: (BuildContext context, StoreDetailsState state) =>
          switch (state) {
            StoreDetailsLoaded(:final items) when items.isEmpty =>
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xl.h),
                  child: Text(
                    Strings.storeDetailsNoItems,
                    style: AppTextStyles.body(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            StoreDetailsLoaded(:final store, :final items, :final loadMore) =>
              SliverList.separated(
                // One extra row for the load-more footer.
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
                itemBuilder: (BuildContext context, int i) => i < items.length
                    ? RestaurantProductCard(item: items[i], storeId: store.id)
                    : LoadMoreFooter(
                        status: loadMore,
                        onRetry: () =>
                            context.read<StoreDetailsCubit>().loadMore(),
                      ),
              ),
            StoreDetailsError(:final failure) => SliverToBoxAdapter(
              child: ErrorText(
                message: failure.userMessage,
                onRetry: () => context.read<StoreDetailsCubit>().load(),
              ),
            ),
            StoreDetailsLoading() => SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.xxl.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          },
    );
  }
}
