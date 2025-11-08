import 'package:flutter/material.dart';

void main() {
  runApp(const FlashCardApp());
}

class FlashCard {
  final String id;
  final String question;
  final String answer;
  bool isExpanded;

  // Allow passing id (so we don't regenerate it when toggling)
  FlashCard({
    required this.question,
    required this.answer,
    this.isExpanded = false,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class FlashCardApp extends StatefulWidget {
  const FlashCardApp({super.key});

  @override
  State<FlashCardApp> createState() => _FlashCardAppState();
}

class _FlashCardAppState extends State<FlashCardApp> {
  // Use the correct key type for SliverAnimatedList
  final GlobalKey<SliverAnimatedListState> _animatedListKey =
  GlobalKey<SliverAnimatedListState>();

  final List<FlashCard> _flashcards = [];
  final List<FlashCard> _learnedCards = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialFlashcards();
  }

  void _loadInitialFlashcards() {
    final initialFlashcards = [
      FlashCard(
        question: "What is Flutter?",
        answer:
        "Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.",
      ),
      FlashCard(
        question: "What is a Widget in Flutter?",
        answer:
        "A Widget is the basic building block of a Flutter app's user interface. Everything in Flutter is a widget.",
      ),
      FlashCard(
        question: "What is the difference between Stateless and Stateful Widget?",
        answer:
        "Stateless widgets are immutable and cannot change, while Stateful widgets can change their state during the widget's lifetime.",
      ),
      FlashCard(
        question: "What is BuildContext?",
        answer:
        "BuildContext is a handle to the location of a widget in the widget tree. It's used to access theme data, navigate, and find other widgets.",
      ),
      FlashCard(
        question: "What is the purpose of setState()?",
        answer:
        "setState() notifies the framework that the internal state of the widget has changed, which triggers a rebuild of the widget and its descendants.",
      ),
    ];

    setState(() {
      _flashcards.clear();
      _flashcards.addAll(initialFlashcards);
      _learnedCards.clear();
    });
  }

  void _markAsLearned(int index) {
    if (index < 0 || index >= _flashcards.length) return;

    final card = _flashcards[index];

    // Remove with animation from SliverAnimatedList
    _animatedListKey.currentState?.removeItem(
      index,
          (context, animation) => _buildRemovedItem(card, animation),
      duration: const Duration(milliseconds: 300),
    );

    // Then mutate underlying list
    setState(() {
      _flashcards.removeAt(index);
      _learnedCards.add(card);
    });
  }

  Widget _buildRemovedItem(FlashCard card, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: Container(
        color: Colors.green.withOpacity(0.2),
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(
            card.question,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text(
            'Marked as learned',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshFlashcards() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final newFlashcards = [
      FlashCard(
        question: "What is Dart?",
        answer: "Dart is the programming language used by Flutter. It's optimized for building user interfaces.",
      ),
      FlashCard(
        question: "What is Hot Reload?",
        answer: "Hot Reload allows developers to quickly see changes in their code without restarting the app, maintaining the app state.",
      ),
      FlashCard(
        question: "What is a Key in Flutter?",
        answer: "A Key is an identifier for Widgets, Elements and SemanticsNodes. It helps Flutter identify when widgets change.",
      ),
      FlashCard(
        question: "What is the widget tree?",
        answer: "The widget tree is the hierarchy of widgets that build your app's user interface.",
      ),
      FlashCard(
        question: "What is the element tree?",
        answer: "The element tree is the instantiation of the widget tree that manages the lifecycle and state of widgets.",
      ),
    ];

    setState(() {
      // For simplicity we replace all items (no animated removal for every item)
      _flashcards.clear();
      _flashcards.addAll(newFlashcards);
      _learnedCards.clear();
      _isRefreshing = false;
    });
  }

  void _addNewFlashcard() {
    final newCard = FlashCard(
      question: "New Question ${_flashcards.length + 1}",
      answer: "This is the answer for the new question. You can customize this content as needed.",
    );

    setState(() {
      // 1) insert in data
      _flashcards.insert(0, newCard);
      // 2) trigger animated insertion on SliverAnimatedList
      _animatedListKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  void _toggleExpansion(int index) {
    if (index < 0 || index >= _flashcards.length) return;

    setState(() {
      // Toggle the existing object's isExpanded flag instead of creating a new FlashCard
      _flashcards[index].isExpanded = !_flashcards[index].isExpanded;
    });
  }

  Widget _buildFlashcardItem(BuildContext context, int index, Animation<double> animation) {
    // Defensive check: if index out of range (can happen during list animation), return empty container
    if (index < 0 || index >= _flashcards.length) {
      return const SizedBox.shrink();
    }

    final card = _flashcards[index];

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Dismissible(
        key: Key(card.id), // stable id for Dismissible
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'MARK LEARNED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle, color: Colors.white, size: 30),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Mark as Learned?'),
              content: const Text('This will remove the card from your current quiz.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Mark Learned'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          // Use the index parameter captured here (closure will have latest index)
          // Note: If list changed before onDismissed fires, index may be stale; we use id fallback.
          final currentIndex = _flashcards.indexWhere((c) => c.id == card.id);
          if (currentIndex != -1) {
            _markAsLearned(currentIndex);
          } else {
            // fallback: remove by id if found in learnedCards or ignore
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            key: Key('tile_${card.id}'),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              card.question,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              card.isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.primary,
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  card.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
            onExpansionChanged: (expanded) => _toggleExpansion(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _flashcards.length + _learnedCards.length;
    final learnedCount = _learnedCards.length;
    final progress = totalCount > 0 ? learnedCount / totalCount : 0.0;

    return MaterialApp(
      title: 'Flashcard Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewFlashcard,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshFlashcards,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Collapsing Header with Progress
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '$learnedCount of $totalCount Learned',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: LinearProgressIndicator(
                            value: progress.toDouble(),
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                            // borderRadius isn't a property on LinearProgressIndicator in stable Flutter
                            // (it is on other widgets). If using Material3 or custom widget, you can wrap.
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}% Complete',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Instructions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_isRefreshing) const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        'Swipe left to mark learned • Tap to reveal answer • Pull to refresh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated List of Flashcards
              if (_flashcards.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'All flashcards learned! 🎉',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pull down to refresh for new questions',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshFlashcards,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Get New Questions'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverAnimatedList(
                  key: _animatedListKey,
                  initialItemCount: _flashcards.length,
                  itemBuilder: (context, index, animation) {
                    return _buildFlashcardItem(context, index, animation);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
