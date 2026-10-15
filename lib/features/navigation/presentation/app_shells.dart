import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

class ClientAppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ClientAppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: AlfNavigationBar(
      index: navigationShell.currentIndex,
      onSelect: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'HOME',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'TRAIN',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum),
          label: 'MESSAGES',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_outlined),
          selectedIcon: Icon(Icons.restaurant),
          label: 'MEALS',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'PROFILE',
        ),
      ],
    ),
  );
}

class TrainerAppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const TrainerAppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: AlfNavigationBar(
      index: navigationShell.currentIndex,
      onSelect: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'OVERVIEW',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'CLIENTS',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'PROGRAMS',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'LIBRARY',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'MORE',
        ),
      ],
    ),
  );
}

class AlfNavigationBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final List<NavigationDestination> destinations;
  const AlfNavigationBar({
    super.key,
    required this.index,
    required this.onSelect,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.subtleBorder)),
      color: AppColors.backgroundBlack,
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    child: Tooltip(
                      message: destinations[i].label,
                      child: InkWell(
                        onTap: () => onSelect(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: i == index
                                      ? AppColors.redTint
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: IconTheme(
                                  data: IconThemeData(
                                    size: 24,
                                    color: i == index
                                        ? AppColors.primaryRed
                                        : AppColors.primaryText,
                                  ),
                                  child: i == index
                                      ? destinations[i].selectedIcon ??
                                            destinations[i].icon
                                      : destinations[i].icon,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                destinations[i].label,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      color: i == index
                                          ? AppColors.primaryRed
                                          : AppColors.primaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
