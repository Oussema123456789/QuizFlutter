import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/service/quiz_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/pages/login.page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'language_provider.dart';


class QuestionPage extends StatefulWidget {
  final String category;
  final String difficulty;
  final int amount;

  const QuestionPage({
    Key? key,
    required this.category,
    required this.difficulty,
    required this.amount,
  }) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();

  int currentQuestionIndex = 0;
  int score = 0;

  bool isAnswered = false;

  String correctAnswer = "";
  String? selectedAnswer;
  List<Map<String, dynamic>> questions = [];
  List<Map<String, String>> incorrectAnswers = [];
  bool isLoading = true;
  int hintsLeft = 1;
  final QuizService quizService = QuizService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int timeLeft = 15;
  Timer? _timer;
  bool isPaused = false;

  final Map<String, int> categoryMap = {
    'Vehicles': 28,
    'Computers': 18,
    'General Knowledge': 9,
    'Video Games': 15,
    'Sports': 21,
    'Mathematics': 19,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initTTS();
    fetchQuestions();
    _animationController.forward();
  }
  void _initTTS() async {
    await _flutterTts.setLanguage("en-US"); // ou "en-US" selon ta langue
    await _flutterTts.setSpeechRate(0.4); // vitesse de lecture
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  void _readQuestion(String text) async {
    await _flutterTts.stop(); // Arrête la lecture précédente
    await _flutterTts.speak(text);
  }
  Future<void> fetchQuestions() async {
    try {
      int categoryId = categoryMap[widget.category] ?? 18;
      List<Map<String, dynamic>> fetchedQuestions = await quizService
          .fetchQuestions(
        amount: widget.amount,
        categoryId: categoryId,
        difficulty: widget.difficulty,
      );
      setState(() {
        questions = fetchedQuestions;
        isLoading = false;
        startTimer();
      });
      _readQuestion(questions[0]["question"]); // Ajoute cette ligne
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text("Erreur", style: GoogleFonts.poppins()),
              content: Text("Impossible de charger les questions.",
                  style: GoogleFonts.poppins()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK", style: GoogleFonts.poppins()),
                ),
              ],
            ),
      );
    }
  }

  void startTimer() {
    _timer?.cancel();
    if (!isPaused) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (timeLeft > 0 && !isPaused) {
            timeLeft--;
          } else if (!isAnswered && !isPaused) {
            checkAnswer("");
          }
        });
      });
    }
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _timer?.cancel();
      } else {
        startTimer();
      }
    });
  }

  Future<void> deconnect() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion: $e")),
      );
    }
  }

  void checkAnswer(String answer) {
    _timer?.cancel();
    setState(() {
      isAnswered = true;
      selectedAnswer = answer;
      correctAnswer = questions[currentQuestionIndex]["correctAnswer"];
      if (answer == correctAnswer) {
        _playSound('sounds/correct.mp3');

        score ++;

      } else {
        _playSound('sounds/wrong.mp3');
        incorrectAnswers.add({
          "question": questions[currentQuestionIndex]["question"],
          "selected": answer.isEmpty ? "Aucune réponse" : answer,
          "correct": correctAnswer,
        });
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (currentQuestionIndex < widget.amount - 1) {
          currentQuestionIndex++;
          isAnswered = false;
          selectedAnswer = null;
          _animationController.forward(from: 0);
          timeLeft = 15;
          _readQuestion(questions[currentQuestionIndex]["question"]);
          startTimer();
        } else {
          _playSound('sounds/complete.mp3');
          showCorrectionResults();
        }
      });
    });
  }

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      print("Error playing sound $path: $e");
    }
  }

  void useHint() {
    if (hintsLeft > 0 && !isAnswered) {
      setState(() {
        List<String> options = List.from(
            questions[currentQuestionIndex]["options"]);
        options.remove(correctAnswer);
        options.shuffle();
        questions[currentQuestionIndex]["options"] =
        [correctAnswer, options.first]..shuffle();
        hintsLeft--;
      });
    }
  }

  void showCorrectionResults() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text("Quiz Terminé!", style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Score: $score / ${widget.amount}",
                      style: GoogleFonts.poppins(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Catégorie: ${widget.category}",
                      style: GoogleFonts.poppins(fontSize: 16)),
                  SizedBox(height: 20),
                  if (incorrectAnswers.isNotEmpty) ...[
                    Text("Corrections :", style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ...incorrectAnswers.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("❓ ${item["question"]}",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                            Text("❌ Votre réponse : ${item["selected"]}",
                                style: GoogleFonts.poppins(color: Colors.red)),
                            Text("✅ Réponse correcte : ${item["correct"]}",
                                style: GoogleFonts.poppins(
                                    color: Colors.green)),
                            Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ] else
                    Text("Parfait ! Toutes les réponses sont correctes 🎉",
                        style: GoogleFonts.poppins()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                    "Retour", style: GoogleFonts.poppins(color: Colors.cyan)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    currentQuestionIndex = 0;
                    score = 0;
                    isAnswered = false;
                    selectedAnswer = null;
                    hintsLeft = 1;
                    timeLeft = 15;
                    incorrectAnswers.clear();
                    fetchQuestions();
                  });
                },
                child: Text("Rejouer", style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  Color getColor(String answer) {
    if (!isAnswered) return Colors.cyan;
    if (answer == correctAnswer) return Colors.green;
    if (answer == selectedAnswer) return Colors.red;
    return Colors.cyan;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.isDarkMode
                  ? [Color(0xFF1F1B24), Color(0xFF3C2F4D)]
                  : [Color(0xFF02B8FF), Color(0xFF02B8FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(child: CircularProgressIndicator(color: Theme
              .of(context)
              .primaryColor)),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? [Color(0xFF1F1B24), Color(0xFF3C2F4D)]
                : [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme
                                    .of(context)
                                    .brightness == Brightness.dark ? Colors
                                    .white : Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Text(
                              "Question ${currentQuestionIndex + 1}/${widget
                                  .amount}",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              onPressed: () => themeProvider.toggleTheme(),
                            ),
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              color: Colors.white,
                              child: IconButton(
                                icon: Icon(Icons.logout, color: Colors.black),
                                onPressed: deconnect,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Progress Bar
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / widget.amount,
                    backgroundColor: Colors.black12,
                    color: Colors.cyan,
                  ),
                  SizedBox(height: 10),
                  // Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 50, height: 50),
                      SizedBox(width: 10),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            "$timeLeft s",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Theme
                                  .of(context)
                                  .brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  // Question
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        question["question"],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Réponses (Grid)
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3,
                      shrinkWrap: true,
                      children: question["options"].map<Widget>((answer) {
                        return GestureDetector(
                          onTap: () => !isAnswered ? checkAnswer(answer) : null,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: getColor(answer),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                answer,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
