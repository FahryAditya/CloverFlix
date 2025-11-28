import 'package:flutter/material.dart';
import '../theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? selectedGenre;
  final String? selectedStatus;
  final String? selectedSort;
  final Function(String?, String?, String?) onApply;

  const FilterBottomSheet({
    super.key,
    this.selectedGenre,
    this.selectedStatus,
    this.selectedSort,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedGenre;
  String? _selectedStatus;
  String? _selectedSort;

  final List<String> _genres = [
    'All',
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Thriller',
  ];

  final List<String> _statuses = [
    'All',
    'RELEASING',
    'FINISHED',
    'NOT_YET_RELEASED',
    'CANCELLED',
  ];

  final List<String> _sorts = [
    'Trending',
    'Popularity',
    'Rating',
    'Recently Updated',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.selectedGenre;
    _selectedStatus = widget.selectedStatus;
    _selectedSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedGenre = null;
                          _selectedStatus = null;
                          _selectedSort = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection('Genre', _genres, _selectedGenre, (value) {
                  setState(() {
                    _selectedGenre = value == 'All' ? null : value;
                  });
                }),
                const SizedBox(height: 16),
                _buildSection('Status', _statuses, _selectedStatus, (value) {
                  setState(() {
                    _selectedStatus = value == 'All' ? null : value;
                  });
                }),
                const SizedBox(height: 16),
                _buildSection('Sort By', _sorts, _selectedSort, (value) {
                  setState(() {
                    _selectedSort = value;
                  });
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        _selectedGenre,
                        _selectedStatus,
                        _selectedSort,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> options,
    String? selected,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option || 
                (selected == null && option == 'All');
            
            return GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accent
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accent
                        : AppTheme.textSecondary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}