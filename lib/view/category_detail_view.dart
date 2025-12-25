import 'package:akilli_ajanda_front/model/category_response.dart';
import 'package:akilli_ajanda_front/view_model/category_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryDetailView extends StatelessWidget {
  final CategoryResponse category;

  const CategoryDetailView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryDetailViewModel()..fetchTasksAndEvents(category.id),
      child: Consumer<CategoryDetailViewModel>(
        builder: (context, viewModel, child) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Görevler'),
                    Tab(text: 'Etkinlikler'),
                  ],
                ),
              ),
              body: Container(
                 decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: TabBarView(
                    children: [
                      _buildTasksList(viewModel),
                      _buildEventsList(viewModel),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList(CategoryDetailViewModel viewModel) {
    if (viewModel.tasks.isEmpty) {
      return const Center(child: Text('Bu kategoride görev yok.', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      itemCount: viewModel.tasks.length,
      itemBuilder: (context, index) {
        final task = viewModel.tasks[index];
        return Card(
          elevation: 4,
          color: Colors.white.withOpacity(0.25),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.white),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            subtitle: Text(task.description ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9))),
          ),
        );
      },
    );
  }

  Widget _buildEventsList(CategoryDetailViewModel viewModel) {
    if (viewModel.events.isEmpty) {
      return const Center(child: Text('Bu kategoride etkinlik yok.', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      itemCount: viewModel.events.length,
      itemBuilder: (context, index) {
        final event = viewModel.events[index];
        return Card(
          elevation: 4,
          color: Colors.white.withOpacity(0.25),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.white),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            subtitle: Text(event.description, style: TextStyle(color: Colors.white.withOpacity(0.9))),
          ),
        );
      },
    );
  }
}
