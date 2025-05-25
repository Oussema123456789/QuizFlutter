import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/pages/question.page.dart';

class CategoriePage extends StatefulWidget {
  const CategoriePage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoriePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String selectedDifficulty = "easy";

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void deconnect() {
    Navigator.of(context).pushReplacementNamed('/'); // redirection vers la page d'accueil ou de login
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Row pour afficher le bouton de déconnexion en haut à droite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Colors.white,
                          child: IconButton(
                            icon: Icon(Icons.logout, color: Colors.black),
                            onPressed: deconnect,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Icon(Icons.quiz, size: 60, color: Colors.cyan.shade900),
                    SizedBox(height: 10),
                    Text(
                      "Catégories",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan.shade900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Choisir le niveau de difficulté",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.cyan.shade900.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      value: selectedDifficulty,
                      dropdownColor: Colors.cyan.shade100,
                      style: GoogleFonts.poppins(color: Colors.cyan.shade900, fontSize: 16),
                      items: ["Easy", "Medium", "Hard"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value.toLowerCase(),
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedDifficulty = value!),
                    ),
                    SizedBox(height: 30),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        buildCategoryButton("Vehicles", Icons.directions_car),
                        buildCategoryButton("Computers", Icons.computer),
                        buildCategoryButton("Video Games", Icons.videogame_asset),
                        buildCategoryButton("General Knowledge", Icons.lightbulb),
                        buildCategoryButton("Sports", Icons.sports_soccer),
                        buildCategoryButton("Mathematics", Icons.how_to_vote),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryButton(String category, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: CategoryButton(
        text: category,
        icon: icon,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionPage(
                category: category,
                difficulty: selectedDifficulty,
                amount: 10,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CategoryButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CategoryButtonState createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isTapped
                ? [Colors.cyan.shade200, Colors.cyan.shade50]
                : [Colors.cyan.shade50, Colors.cyan.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _isTapped ? 4 : 8,
              offset: Offset(0, _isTapped ? 2 : 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        transform: Matrix4.identity()..scale(_isTapped ? 0.98 : 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.cyan.shade900, size: 24),
            SizedBox(width: 10),
            Text(
              widget.text,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.cyan.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
