import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/widgets/task_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_remider_app/screens/add_task.dart';
import 'package:task_remider_app/screens/user_profile.dart';
import 'package:task_remider_app/services/user_service.dart';
import 'package:task_remider_app/data/task_service.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();
  String _selectedCategory = 'All Tasks';
  String _selectedPriorityFilter = 'All Priorities';

  final List<String> _categories = [
    'All Tasks',
    'Today Tasks',
    'Future',
    'Completed',
  ];

  // Event handlers for better separation of concerns
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _logEvent('Category changed to: $category');
  }

  void _onPriorityFilterChanged(String priority) {
    setState(() {
      _selectedPriorityFilter = priority;
    });
    _logEvent('Priority filter changed to: $priority');
  }

  void _logEvent(String event) {
    debugPrint('[HomeScreen Event] $event at ${DateTime.now()}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleTaskCompletion(QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final currentStatus = data['isCompleted'] ?? false;
    final taskTitle = data['title'] ?? 'Unknown Task';

    _logEvent('Attempting to toggle task completion: $taskTitle');

    try {
      await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
        'isCompleted': !currentStatus,
      });

      _onTaskCompletionToggled(taskTitle, !currentStatus);
    } catch (e) {
      _onTaskError('Failed to update task completion', e);
    }
  }

  void _onTaskCompletionToggled(String taskTitle, bool isCompleted) {
    _logEvent(
      'Task completion toggled: $taskTitle -> ${isCompleted ? 'completed' : 'incomplete'}',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted ? 'Task completed!' : 'Task marked as incomplete',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isCompleted ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTaskError(String message, dynamic error) {
    _logEvent('Task error: $message - $error');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterTasksByCategory(
    List<QueryDocumentSnapshot> tasks,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedCategory) {
      case 'All Tasks':
        return tasks;
      case 'Today Tasks':
        return tasks.where((task) {
          final data = task.data() as Map<String, dynamic>;
          final dateStr = data['date'] as String?;
          if (dateStr == null || dateStr.isEmpty) return false;

          try {
            // Parse date in DD/MM/YYYY format
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final taskDate = DateTime(year, month, day);
              return taskDate.isAtSameMomentAs(today);
            }
          } catch (e) {
            // If date parsing fails, exclude the task
          }
          return false;
        }).toList();
      case 'Future':
        return tasks.where((task) {
          final data = task.data() as Map<String, dynamic>;
          final dateStr = data['date'] as String?;
          if (dateStr == null || dateStr.isEmpty) return false;

          try {
            // Parse date in DD/MM/YYYY format
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final taskDate = DateTime(year, month, day);
              final tomorrow = today.add(const Duration(days: 1));
              return taskDate.isAfter(today) ||
                  taskDate.isAtSameMomentAs(tomorrow);
            }
          } catch (e) {
            // If date parsing fails, exclude the task
          }
          return false;
        }).toList();
      case 'Completed':
        return tasks.where((task) {
          final data = task.data() as Map<String, dynamic>;
          return data['isCompleted'] == true;
        }).toList();
      default:
        return tasks;
    }
  }

  List<QueryDocumentSnapshot> _filterTasksByPriority(
    List<QueryDocumentSnapshot> tasks,
  ) {
    if (_selectedPriorityFilter == 'All Priorities') {
      return tasks;
    }

    return tasks.where((task) {
      final data = task.data() as Map<String, dynamic>;
      final priority = (data['priority'] as String? ?? '').toLowerCase();
      return priority == _selectedPriorityFilter.toLowerCase();
    }).toList();
  }

  Map<String, int> _getTaskCounts(List<QueryDocumentSnapshot> allTasks) {
    final counts = <String, int>{};

    for (final category in _categories) {
      final originalCategory = _selectedCategory;
      _selectedCategory = category;
      final filteredTasks = _filterTasksByCategory(allTasks);
      counts[category] = filteredTasks.length;
      _selectedCategory = originalCategory;
    }

    return counts;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All Tasks':
        return Icons.list_alt;
      case 'Today Tasks':
        return Icons.today;
      case 'Future':
        return Icons.schedule;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Task Reminder',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _userService.getUserInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        backgroundColor: Color(0xFF8687E7),
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Selection with compact design
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategoryChanged(category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            color: isSelected ? Colors.white : primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.split(
                              ' ',
                            )[0], // Show only first word to save space
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Priority Filter Dropdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Filter by Priority:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPriorityFilter,
                          isExpanded: true,
                          items: ['All Priorities', 'High', 'Medium', 'Low']
                              .map(
                                (priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(
                                    priority,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: priority == 'High'
                                          ? priorityHigh
                                          : priority == 'Medium'
                                          ? priorityMedium
                                          : priority == 'Low'
                                          ? priorityLow
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              _onPriorityFilterChanged(value!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tasks List
            Expanded(
              child: StreamBuilder(
                stream: _taskService.getTasksQueryStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tasks found'));
                  }

                  final allTasks = snapshot.data!.docs;

                  // Sort tasks by createdAt (newest first) to maintain consistent ordering
                  allTasks.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aCreatedAt = aData['createdAt'] as Timestamp?;
                    final bCreatedAt = bData['createdAt'] as Timestamp?;

                    if (aCreatedAt == null && bCreatedAt == null) return 0;
                    if (aCreatedAt == null) return 1;
                    if (bCreatedAt == null) return -1;
                    return bCreatedAt.compareTo(aCreatedAt);
                  });

                  final taskCounts = _getTaskCounts(allTasks);

                  // Filter tasks based on selected category and priority
                  final categoryFilteredTasks = _filterTasksByCategory(
                    allTasks,
                  );
                  final filteredTasks = _filterTasksByPriority(
                    categoryFilteredTasks,
                  );

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No $_selectedCategory found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Task Summary Section
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.1),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _categories.map((category) {
                            final count = taskCounts[category] ?? 0;
                            final isSelected = category == _selectedCategory;
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(
                                          alpha: 0.2,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category),
                                    color: isSelected
                                        ? Colors.white
                                        : primaryColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  category.split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      // Category Header with count
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(_selectedCategory),
                              color: primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedCategory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredTasks.length} ${filteredTasks.length == 1 ? 'task' : 'tasks'}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tasks List
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final doc = filteredTasks[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Task_Widget(
                                taskData: {
                                  ...doc.data() as Map<String, dynamic>,
                                  'id': doc.id,
                                },
                                onToggleComplete: () =>
                                    _toggleTaskCompletion(doc),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
