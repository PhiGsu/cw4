import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PlanManagerScreen(),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [
    Plan(
        name: 'Adopt a Pet',
        description: 'A man on the corner sells a snake.',
        date: DateTime(2025, 3, 28),
        completed: true),
    Plan(
        name: 'Trip to Paris',
        description: 'Oui oui baguette.',
        date: DateTime(2025, 5, 10),
        completed: true),
    Plan(
      name: 'Adopt a Child',
      description: 'Fill the empty void in your life.',
      date: DateTime(2025, 7, 3),
    ),
    Plan(
      name: 'Trip to Japan',
      description: 'I need to up the score on Godzilla.',
      date: DateTime(2025, 11, 24),
    ),
  ];

  void _addPlan(Plan plan) {
    setState(() {
      plans.add(plan);
    });
  }

  void _updatePlan(int index, Plan plan) {
    setState(() {
      plans[index] = plan;
    });
  }

  void _completePlan(int index, bool complete) {
    setState(() {
      plans[index].completed = complete;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _showCreatePlanDialog(int? editIndex) {
    final TextEditingController planName = TextEditingController();
    final TextEditingController planDescription = TextEditingController();
    DateTime planDate = DateTime.now();

    if (editIndex != null) {
      Plan editPlan = plans[editIndex];
      planName.text = editPlan.name;
      planDescription.text = editPlan.description;
      planDate = editPlan.date;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Create plan'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                      controller: planName,
                      decoration: InputDecoration(labelText: 'Plan Name')),
                  TextField(
                      controller: planDescription,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: null),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: planDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        planDate = pickedDate;
                      }
                    },
                    child: const Text('Pick a date'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (planName.text.isEmpty || planDescription.text.isEmpty) {
                    return;
                  }
                  Plan newPlan = Plan(
                      name: planName.text,
                      description: planDescription.text,
                      date: planDate);
                  editIndex == null
                      ? _addPlan(newPlan)
                      : _updatePlan(editIndex, newPlan);
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Plan Manager'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final Plan item = plans.removeAt(oldIndex);
                        plans.insert(newIndex, item);
                      });
                    },
                    children: List.generate(plans.length, (index) {
                      final plan = plans[index];
                      return GestureDetector(
                        key: Key('$index'),
                        onHorizontalDragUpdate: (details) {
                          // On swipe left
                          if (details.primaryDelta! < 0) {
                            _completePlan(index, false);
                          }
                          // On swipe right
                          if (details.primaryDelta! > 0) {
                            _completePlan(index, true);
                          }
                        },
                        onLongPress: () {
                          _showCreatePlanDialog(index);
                        },
                        onDoubleTap: () => _deletePlan(index),
                        child: Card(
                            child: ListTile(
                            title: Text(plan.name),
                            subtitle: Text(plan.description),
                            leading: plan.completed
                              ? const Icon(Icons.check_circle,
                                color: Colors.green)
                              : const Icon(Icons.circle_outlined,
                                color: Colors.cyan),
                            trailing: Text('${plan.date.toString().substring(0, 10)}  '),
                          ),
                        ),
                      );
                    })))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlanDialog(null),
        tooltip: 'Create Plan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool completed;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.completed = false,
  });
}
