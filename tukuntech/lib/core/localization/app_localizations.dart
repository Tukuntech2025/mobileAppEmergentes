import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Role Selection / Welcome
      'welcome_title': 'Welcome to TukunTech',
      'welcome_subtitle': 'Choose your role to continue.',
      'role_patient_caregiver': 'I\'m a patient or caregiver',
      'role_patient_caregiver_sub': 'Sign in with your email. The system will recognize your access automatically.',
      'lang_en': 'English',
      'lang_es': 'Spanish',
      
      // Auth / Login
      'sign_in': 'Sign in',
      'forgot_password': 'Forgot password?',
      'enter_credentials': 'Enter your credentials to continue.',
      'email_label': 'Email',
      'password_label': 'Password',
      'dont_have_account': 'Don\'t have an account?',
      'create_one': 'Create one',
      'choose_different_role': '← Choose a different role',
      'patient_caregiver_badge': 'Patient / Caregiver',
      'error_unauthorized_role': 'Access denied: Unauthorized role',
      'error_no_token': 'No token received',
      'error_profile_fetch': 'Failed to fetch profile info',
      'login_failed': 'Login failed',
      'error_label': 'Error',
      
      // General / Navigation
      'confirm_logout': 'Confirm Logout',
      'logout_message': 'Are you sure you want to log out of your session?',
      'cancel': 'Cancel',
      'log_out': 'Log out',
      'menu': 'Menu',
      'settings': 'Settings',
      'support': 'Support',
      
      // Settings Body
      'personalize_app': 'Personalize your app!',
      'save': 'Save',
      'language': 'Language',
      'preferred_language': 'Choose your preferred app language',
      'app_language': 'App language',
      'language_saved': 'Language set to',

      // Support Body
      'support_greeting': 'We\'re here whenever you need us.',
      'call_us': 'Call us',
      'send_message': 'Send us a message',
      'subject': 'Subject',
      'description': 'Description',
      'send': 'Send',
      'history_tickets': 'History tickets',
      'no_tickets': 'No tickets submitted yet.',
      'date': 'Date',
      'status': 'Status',
      'emergency_disclaimer': 'In case of an emergency, Tukuntech will call the emergency numbers. ',
      'emergency_network_req': 'It needs that it is connected to the network to function correctly.',
      'err_empty_ticket': 'Please enter a subject and description',
      'ticket_sent_success': 'Ticket sent successfully',
      'ticket_send_failed': 'Error sending ticket',

      // Patient Profile Body
      'my_profile': 'My profile',
      'profile_subtitle': 'Personal information and emergency contacts.',
      'years_old': 'years old',
      'personal_info': 'Personal information',
      'full_name': 'Full name',
      'age': 'Age',
      'gender': 'Gender',
      'address': 'Address',
      'blood_type': 'Blood type',
      'save_changes': 'Save changes',
      'emergency_contacts': 'Emergency contacts',
      'add_contacts_here': 'Here you can add your emergency\ncontacts',
      'add': 'Add',
      'no_contacts': 'No emergency contacts added yet.',
      'name': 'Name',
      'relation': 'Relation',
      'phone': 'Phone',
      'add_emergency_contact': 'Add emergency contact',
      'enter_emergency_info': 'Enter the contact information for\nemergency situations.',
      'changes_saved_success': 'Changes saved successfully',
      'error_saving_changes': 'Error saving changes',

      // Device Body
      'my_device': 'My device',
      'device_status_subtitle': 'Status and conection details for your TukunTech IOT',
      'device_name': 'TukunTech IOT',
      'version': 'Version',
      'online': 'Online',
      'battery': 'Battery',
      'wifi': 'WiFi',
      'sync': 'Sync',
      'strong': 'Strong',
      'good': 'Good',
      'device_normal_alert': 'Your device is reporting normally. We\'ll notify you here if anything changes.',
      'add_device_title': 'Add New Device',
      'device_name_field': 'Device Name',
      'device_id_field': 'Device ID / Serial Number',
      'device_model_field': 'Model',
      'register_device_btn': 'Register Device',
      'device_added_success': 'Device registered successfully',

      // Report Body
      'my_history': 'My history',
      'history_subtitle': 'Your recent vital signs - heart rate, oxygen, and temperature.',
      'generate_report': 'Generate report',
      'export_report_sub': 'Export a vital signs summary report',
      'period': 'Period',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'vital_signs_history': 'Vital signs history',
      'no_reports': 'No reports available for this period.',
      'bpm_avg': 'bpm avg.',
      'avg': 'avg.',
      'normal_status': 'normal',
      'abnormal_status': 'abnormal',
      'err_timeout': 'Connection timed out. Backend is not reachable.',
      'err_connection': 'Connection error. Check your backend.',
      'err_failed_load': 'Failed to load',
      'err_failed_generate': 'Failed to generate',

      // Vital Signs / Dashboard
      'patient_role': 'patient',
      'vital_signs': 'Vital Signs',
      'activity_today': 'Detail view of today\'s activity',
      'heart_rate': 'Heart rate',
      'oxygen_label': 'Oxygen',
      'temperature_label': 'Temperature',
      'resting_normal': 'Resting - normal',
      'spo2': 'SpO2',
      'normal': 'Normal',
      'heart_rate_live': 'Heart rate - live',
      'ecg_description': 'Real-time electrocardiogram waveform from the wearable',
      'hello': 'Hello',
      'greeting_calm': 'all good! You are feeling calm.',
      'calm_stable': 'Calm and stable',
      'warning': 'WARNING',

      // Caregiver Dashboard
      'caregiver_role': 'caregiver',
      'patient_devices': 'Patient devices',
      'device_status_sub': 'Status and conection details for your TukunTech IOT',
      'alert_low_oxygen': 'Alert! low oxygen',
      'low_oxygen': 'Low Oxygen',
      'slight_hr_variability': 'Slight HR variability',
      'waiting_device_conn': 'Waiting for device connection...',
      'pending': 'Pending',
      'no_data': 'No data',
      'reports': 'Reports',

      // Caregiver Profile Body
      'patient_profile': 'Patient profile',
      'caregiver_profile_sub': 'Personal information, subscription, and emergency contacts.',
      'limit_5_patients': 'You can only have up to 5 patients.',
      'add_new_patient': 'Add new patient',
      'enter_patient_info': 'Enter the new patient information.',
      'cancel_subscription': 'Cancel subscription',
      'confirm_cancel_sub': 'Are you sure you want to cancel the TukunTech Premium subscription for this patient?',
      'no_keep_it': 'No, keep it',
      'subscription_cancelled': 'Subscription cancelled',
      'no_patients_assigned': 'No patients assigned.',
      'add_patient': 'Add patient',
      'subscription': 'Subscription',
      'active': 'Active',
      'plan': 'Plan',
      'personal_pro_monthly': 'Personal Pro - monthly',
      'renew_message': 'Renews on June 9, 2026. - \$200',
      'renew_subscription': 'Renew subscription',
      'subscription_renewed': 'Subscription renewed!',

      // Caregiver Patient History
      'patient_history': 'Patient history',
      'patient_history_sub': 'Patient recent vital signs - heart rate, oxygen, and temperature.',
      'patient_label': 'Patient',

      // Other Card Elements
      'device_label': 'Device',
    },
    'es': {
      // Role Selection / Welcome
      'welcome_title': 'Bienvenido a TukunTech',
      'welcome_subtitle': 'Selecciona tu rol para continuar.',
      'role_patient_caregiver': 'Soy un paciente o cuidador',
      'role_patient_caregiver_sub': 'Inicia sesión con tu correo. El sistema reconocerá tu acceso automáticamente.',
      'lang_en': 'Inglés',
      'lang_es': 'Español',
      
      // Auth / Login
      'sign_in': 'Iniciar sesión',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'enter_credentials': 'Ingresa tus credenciales para continuar.',
      'email_label': 'Correo electrónico',
      'password_label': 'Contraseña',
      'dont_have_account': '¿No tienes una cuenta?',
      'create_one': 'Crea una',
      'choose_different_role': '← Elegir un rol diferente',
      'patient_caregiver_badge': 'Paciente / Cuidador',
      'error_unauthorized_role': 'Acceso denegado: Rol no autorizado',
      'error_no_token': 'No se recibió ningún token',
      'error_profile_fetch': 'Error al obtener información del perfil',
      'login_failed': 'Error al iniciar sesión',
      'error_label': 'Error',
      
      // General / Navigation
      'confirm_logout': 'Confirmar cierre de sesión',
      'logout_message': '¿Estás seguro de que deseas cerrar sesión?',
      'cancel': 'Cancelar',
      'log_out': 'Cerrar sesión',
      'menu': 'Menú',
      'settings': 'Ajustes',
      'support': 'Soporte',
      
      // Settings Body
      'personalize_app': '¡Personaliza tu app!',
      'save': 'Guardar',
      'language': 'Idioma',
      'preferred_language': 'Elige tu idioma de preferencia',
      'app_language': 'Idioma de la app',
      'language_saved': 'Idioma configurado en',

      // Support Body
      'support_greeting': 'Estamos aquí cuando nos necesites.',
      'call_us': 'Llámanos',
      'send_message': 'Envíanos un mensaje',
      'subject': 'Asunto',
      'description': 'Descripción',
      'send': 'Enviar',
      'history_tickets': 'Historial de tickets',
      'no_tickets': 'No se han enviado tickets aún.',
      'date': 'Fecha',
      'status': 'Estado',
      'emergency_disclaimer': 'En caso de emergencia, Tukuntech llamará a los números de emergencia. ',
      'emergency_network_req': 'Se requiere conexión a la red para funcionar correctamente.',
      'err_empty_ticket': 'Por favor, ingresa un asunto y una descripción',
      'ticket_sent_success': 'Ticket enviado exitosamente',
      'ticket_send_failed': 'Error al enviar el ticket',

      // Patient Profile Body
      'my_profile': 'Mi perfil',
      'profile_subtitle': 'Información personal y contactos de emergencia.',
      'years_old': 'años',
      'personal_info': 'Información personal',
      'full_name': 'Nombre completo',
      'age': 'Edad',
      'gender': 'Género',
      'address': 'Dirección',
      'blood_type': 'Grupo sanguíneo',
      'save_changes': 'Guardar cambios',
      'emergency_contacts': 'Contactos de emergencia',
      'add_contacts_here': 'Aquí puedes agregar tus\ncontactos de emergencia',
      'add': 'Agregar',
      'no_contacts': 'No se han agregado contactos de emergencia aún.',
      'name': 'Nombre',
      'relation': 'Parentesco',
      'phone': 'Teléfono',
      'add_emergency_contact': 'Agregar contacto de emergencia',
      'enter_emergency_info': 'Ingresa la información de contacto para situaciones de emergencia.',
      'changes_saved_success': 'Cambios guardados con éxito',
      'error_saving_changes': 'Error al guardar cambios',

      // Device Body
      'my_device': 'Mi dispositivo',
      'device_status_subtitle': 'Estado y detalles de conexión de tu TukunTech IOT',
      'device_name': 'TukunTech IOT',
      'version': 'Versión',
      'online': 'En línea',
      'battery': 'Batería',
      'wifi': 'WiFi',
      'sync': 'Sincro',
      'strong': 'Fuerte',
      'good': 'Buena',
      'device_normal_alert': 'Tu dispositivo está reportando normalmente. Te notificaremos aquí si algo cambia.',
      'add_device_title': 'Agregar nuevo dispositivo',
      'device_name_field': 'Nombre del dispositivo',
      'device_id_field': 'ID del dispositivo / Número de serie',
      'device_model_field': 'Modelo',
      'register_device_btn': 'Registrar dispositivo',
      'device_added_success': 'Dispositivo registrado con éxito',

      // Report Body
      'my_history': 'Mi historial',
      'history_subtitle': 'Tus signos vitales recientes: frecuencia cardíaca, oxígeno y temperatura.',
      'generate_report': 'Generar reporte',
      'export_report_sub': 'Exportar un reporte de resumen de signos vitales',
      'period': 'Período',
      'daily': 'Diario',
      'weekly': 'Semanal',
      'monthly': 'Mensual',
      'yearly': 'Anual',
      'vital_signs_history': 'Historial de signos vitales',
      'no_reports': 'No hay reportes disponibles para este período.',
      'bpm_avg': 'lpm prom.',
      'avg': 'prom.',
      'normal_status': 'normal',
      'abnormal_status': 'anormal',
      'err_timeout': 'Tiempo de espera agotado. El backend no está accesible.',
      'err_connection': 'Error de conexión. Verifica tu backend.',
      'err_failed_load': 'Error al cargar',
      'err_failed_generate': 'Error al generar',

      // Vital Signs / Dashboard
      'patient_role': 'paciente',
      'vital_signs': 'Signos Vitales',
      'activity_today': 'Vista detallada de la actividad de hoy',
      'heart_rate': 'Frecuencia cardíaca',
      'oxygen_label': 'Oxígeno',
      'temperature_label': 'Temperatura',
      'resting_normal': 'En reposo - normal',
      'spo2': 'SpO2',
      'normal': 'Normal',
      'heart_rate_live': 'Frecuencia cardíaca - en vivo',
      'ecg_description': 'Onda de electrocardiograma en tiempo real desde el dispositivo',
      'hello': 'Hola',
      'greeting_calm': '¡todo bien! Te sientes tranquilo.',
      'calm_stable': 'Tranquilo y estable',
      'warning': 'ADVERTENCIA',

      // Caregiver Dashboard
      'caregiver_role': 'cuidador',
      'patient_devices': 'Dispositivos de pacientes',
      'device_status_sub': 'Estado y detalles de conexión de tu TukunTech IOT',
      'alert_low_oxygen': '¡Alerta! Oxígeno bajo',
      'low_oxygen': 'Oxígeno bajo',
      'slight_hr_variability': 'Variación leve de FC',
      'waiting_device_conn': 'Esperando conexión del dispositivo...',
      'pending': 'Pendiente',
      'no_data': 'Sin datos',
      'reports': 'Reportes',

      // Caregiver Profile Body
      'patient_profile': 'Perfil del paciente',
      'caregiver_profile_sub': 'Información personal, suscripción y contactos de emergencia.',
      'limit_5_patients': 'Solo puedes tener hasta 5 pacientes.',
      'add_new_patient': 'Agregar nuevo paciente',
      'enter_patient_info': 'Ingresa la información del nuevo paciente.',
      'cancel_subscription': 'Cancelar suscripción',
      'confirm_cancel_sub': '¿Estás seguro de que deseas cancelar la suscripción TukunTech Premium para este paciente?',
      'no_keep_it': 'No, mantenerla',
      'subscription_cancelled': 'Suscripción cancelada',
      'no_patients_assigned': 'No hay pacientes asignados.',
      'add_patient': 'Agregar paciente',
      'subscription': 'Suscripción',
      'active': 'Activo',
      'plan': 'Plan',
      'personal_pro_monthly': 'Personal Pro - mensual',
      'renew_message': 'Se renueva el 9 de junio de 2026. - \$200',
      'renew_subscription': 'Renovar suscripción',
      'subscription_renewed': '¡Suscripción renovada!',

      // Caregiver Patient History
      'patient_history': 'Historial de pacientes',
      'patient_history_sub': 'Signos vitales recientes del paciente: frecuencia cardíaca, oxígeno y temperatura.',
      'patient_label': 'Paciente',

      // Other Card Elements
      'device_label': 'Dispositivo',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String translate(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
