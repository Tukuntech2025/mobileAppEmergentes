import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';
import 'package:tukuntech/core/localization/language_manager.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  static const Color _primary = Color(0xFF3B9784);

  late String _selectedLanguage;
  final List<String> _languages = [
    'English',
    'Spanish',
  ];

  @override
  void initState() {
    super.initState();
    final currentLocale = LanguageManager.instance.currentLocale.languageCode;
    _selectedLanguage = currentLocale == 'es' ? 'Spanish' : 'English';
  }

  void _save() {
    final newLocale = _selectedLanguage == 'Spanish' ? const Locale('es') : const Locale('en');
    LanguageManager.instance.setLocale(newLocale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.translate('language_saved')} ${context.translate(_selectedLanguage == 'Spanish' ? 'lang_es' : 'lang_en')}'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ── Header ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('settings'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.translate('personalize_app'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(context.translate('save')),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Card: Language ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.language,
                      color: _primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('language'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.translate('preferred_language'),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                context.translate('app_language'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                ),
                items: _languages
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(context.translate(l == 'Spanish' ? 'lang_es' : 'lang_en')),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
