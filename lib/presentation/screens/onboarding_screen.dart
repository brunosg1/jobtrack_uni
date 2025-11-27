import 'package:flutter/material.dart';
import 'package:jobtrack_uni/presentation/screens/home_screen.dart';
import 'package:jobtrack_uni/presentation/screens/policy_viewer.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _privacyPolicyRead = false;
  bool _termsOfUseRead = false;
  bool _consentGiven = false;

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  void _loadReadStatus() {
     final prefsService = Provider.of<PrefsService>(context, listen: false);
     setState(() {
       _privacyPolicyRead = prefsService.getPrivacyPolicyRead();
       _termsOfUseRead = prefsService.getTermsOfUseRead();
     });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _navigateToPolicyViewer(String assetPath, String title, Function onRead) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PolicyViewer(
      markdownAssetPath: assetPath,
      title: title,
    ))).then((read) {
      if (read == true) {
        onRead();
        _loadReadStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefsService = Provider.of<PrefsService>(context, listen: false);
    final theme = Theme.of(context);
    final canGiveConsent = _privacyPolicyRead && _termsOfUseRead;
    final canFinish = canGiveConsent && _consentGiven;
    
    final onboardingPages = [
      _buildPage(
        icon: Icons.lightbulb_outline,
        title: "Bem-vindo ao JobTrack Uni!",
        description: "Organize seu portfólio e acompanhe suas candidaturas de estágio em um só lugar.",
      ),
      _buildPage(
        icon: Icons.checklist_rtl,
        title: "Como Funciona",
        description: "Crie cards para cada vaga, anexe seu portfólio e nunca mais perca uma oportunidade.",
      ),
      _buildConsentPage(theme, prefsService, canGiveConsent, canFinish),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botão Pular (RF-2)
            if (_currentPage < onboardingPages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _pageController.jumpToPage(onboardingPages.length - 1),
                  child: const Text('Pular'),
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: onboardingPages,
              ),
            ),
            // Navegação e Dots (RF-1)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Voltar
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          ),
                          child: const Text('Voltar'),
                        )
                      : const SizedBox(width: 60),

                  // Dots (RF-1)
                  if (_currentPage < onboardingPages.length -1)
                    SmoothPageIndicator(
                        controller: _pageController,
                        count: onboardingPages.length,
                        effect: WormEffect(
                          dotColor: Colors.grey,
                          activeDotColor: theme.colorScheme.secondary,
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                      ),
                  
                  // Botão Avançar / Finalizar
                  _currentPage < onboardingPages.length - 1
                      ? TextButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          ),
                          child: const Text('Avançar'),
                        )
                      : ElevatedButton(
                          onPressed: canFinish ? () async {
                              await prefsService.saveConsent();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                          } : null, // Botão desabilitado (RNF-A11Y)
                          child: const Text('Começar'),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 40),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(description, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
  
  Widget _buildConsentPage(ThemeData theme, PrefsService prefsService, bool canGiveConsent, bool canFinish) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Consentimento", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text("Antes de começar, precisamos da sua permissão. Por favor, leia e aceite nossos documentos.", style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          
          // Links para políticas
          _buildPolicyLink(
            context,
            title: "Política de Privacidade",
            read: _privacyPolicyRead,
            onTap: () => _navigateToPolicyViewer('assets/privacy_policy.md', 'Política de Privacidade', () async {
              await prefsService.setPrivacyPolicyRead(true);
            }),
          ),
          const SizedBox(height: 15),
          _buildPolicyLink(
            context,
            title: "Termos de Uso",
            read: _termsOfUseRead,
            onTap: () => _navigateToPolicyViewer('assets/terms_of_use.md', 'Termos de Uso', () async {
              await prefsService.setTermsOfUseRead(true);
            }),
          ),
          
          const SizedBox(height: 30),
          // Checkbox de consentimento (RF-4)
          CheckboxListTile(
            title: const Text("Li e aceito os termos."),
            value: _consentGiven,
            onChanged: canGiveConsent ? (bool? value) {
              setState(() {
                _consentGiven = value ?? false;
              });
            } : null, // Desabilitado até ler os docs
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyLink(BuildContext context, {required String title, required bool read, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(decoration: TextDecoration.underline)),
            Icon(
              read ? Icons.check_circle : Icons.radio_button_unchecked,
              color: read ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
