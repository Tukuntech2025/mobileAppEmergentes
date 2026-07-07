import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

class SupportTicket {
  final String subject;
  final String date;
  String status; // 'Done' | 'Outstanding' | 'Pending'
  SupportTicket({
    required this.subject,
    required this.date,
    required this.status,
  });
}

class SupportBody extends StatefulWidget {
  const SupportBody({super.key});

  @override
  State<SupportBody> createState() => _SupportBodyState();
}

class _SupportBodyState extends State<SupportBody> {
  static const Color _primary = Color(0xFF3B9784);

  final TextEditingController _subjectCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  List<SupportTicket> _tickets = [];
  bool _isLoadingTickets = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final token = AuthStore.token;
      if (token == null) return;
      
      final String baseUrl = EnvironmentConfig.baseUrl;

      // Fetch tickets
      final res = await ApiClient.get(
        Uri.parse('$baseUrl/tickets/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        
        final loadedTickets = data.map((json) {
          final createdAt = json['createdAt'] as String? ?? '';
          final dateStr = createdAt.length >= 10 ? createdAt.substring(0, 10) : '';
          
          return SupportTicket(
            subject: json['subject'] ?? 'No subject',
            date: dateStr,
            status: json['status'] ?? 'OPEN',
          );
        }).toList();

        if (mounted) {
          setState(() {
            _tickets = loadedTickets;
            _isLoadingTickets = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTickets = false);
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      if (mounted) {
        setState(() => _isLoadingTickets = false);
      }
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }


  Future<void> _sendTicket() async {
    final subject = _subjectCtrl.text.trim();
    final description = _descCtrl.text.trim();
    if (subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('err_empty_ticket')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token");

      final String baseUrl = EnvironmentConfig.baseUrl;

      // 1. Fetch profile to get email
      final profileRes = await ApiClient.get(
        Uri.parse('$baseUrl/profiles/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (profileRes.statusCode != 200 && profileRes.statusCode != 201) {
        throw Exception("Failed to fetch profile to get email");
      }
      
      final profileData = jsonDecode(utf8.decode(profileRes.bodyBytes));
      final String contactEmail = profileData['email'] ?? "unknown@example.com";

      if (contactEmail == "unknown@example.com") {
        print("Warning: email was not found in profile response: $profileData");
      }

      // 2. Post ticket
      final body = jsonEncode({
        "contactEmail": contactEmail,
        "subject": subject,
        "description": description
      });

      final res = await ApiClient.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        _subjectCtrl.clear();
        _descCtrl.clear();
        _fetchTickets(); // Refresh tickets from backend
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('ticket_sent_success')),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception("Failed to send ticket");
      }
    } catch (e) {
      print('Error sending ticket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.translate('ticket_send_failed')}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'DONE':
      case 'RESOLVED':
      case 'CLOSED':
        return _primary;
      case 'OUTSTANDING':
      case 'IN_PROGRESS':
        return const Color(0xFFF9A825);
      case 'PENDING':
      case 'OPEN':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ── Header ──────────────────────────────────────────────
        Text(
          context.translate('support'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.translate('support_greeting'),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),

        // ── Card: Call us ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.phone_outlined,
                  color: _primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('call_us'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '(51) 444-222-333',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Card: Send us a message ─────────────────────────────
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('send_message'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              // Subject
              Text(
                context.translate('subject'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(controller: _subjectCtrl, decoration: _inputDeco()),
              const SizedBox(height: 12),
              // Description
              Text(
                context.translate('description'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: _inputDeco(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _sendTicket,
                  icon: const Icon(Icons.send, size: 16),
                  label: Text(context.translate('send')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Card: History tickets ───────────────────────────────
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('history_tickets'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              if (_isLoadingTickets)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_tickets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    context.translate('no_tickets'),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                )
              else
                ..._tickets.map(
                (t) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('subject'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          t.subject,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translate('date'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    t.date,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translate('status'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(t.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    t.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Banner de emergencia ─────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: context.translate('emergency_disclaimer'),
                      ),
                      TextSpan(
                        text: context.translate('emergency_network_req'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF0FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

