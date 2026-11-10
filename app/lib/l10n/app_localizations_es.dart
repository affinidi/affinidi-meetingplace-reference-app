// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Lugar de encuentro';

  @override
  String tabsTitle(String tabName) {
    String _temp0 = intl.Intl.selectLogic(tabName, {
      'connections': 'Invitaciones',
      'contacts': 'Comunidades',
      'identities': 'Identidades',
      'rCards': 'Tarjetas-R',
      'settings': 'Configuración',
      'other': 'Inválido',
    });
    return '$_temp0';
  }

  @override
  String get rCardsPlaceholderMessage => 'Las R-Cards aparecerán aquí.';

  @override
  String get publishOffer => 'Publicar invitación';

  @override
  String get publishGroupOffer => 'Publicar invitación de grupo';

  @override
  String get meetingPlaceBannerText =>
      'Meeting Place le permite publicar de forma anónima y privada una invitación para conectarse con usted. Proporcione un título y una descripción, así como detalles de validez para limitar el tiempo que la oferta está disponible.';

  @override
  String get connectionOfferDetails => 'Detalles de la invitación';

  @override
  String get createGroupChatOffer => 'Chat grupal';

  @override
  String get chatTransport => 'Transporte de chat';

  @override
  String transportLabel(String transport) {
    String _temp0 = intl.Intl.selectLogic(transport, {
      'didcomm': 'DIDComm',
      'matrix': 'Matrix',
      'other': '$transport',
    });
    return '$_temp0';
  }

  @override
  String get groupOfferHelperText =>
      'La invitación representará un chat grupal para que varios contactos se unan y chateen. Todavía tienes control sobre quién puede unirse al chat grupal.';

  @override
  String get generateRandomPhraseHelperEnabled => 'Generar una frase aleatoria';

  @override
  String get generateRandomPhraseHelperDisabled =>
      'La frase personalizada que ingrese se utilizará para identificar de manera única esta invitación a conectarse. Debe ser único en el universo de Meeting Place.';

  @override
  String get customPhrase => 'Frase personalizada';

  @override
  String get enterCustomPhrase => 'Introducir frase personalizada';

  @override
  String get customPhraseHelperText =>
      'Introduzca una frase personalizada única. Puedes usar tantas palabras como quieras, separadas por espacios.';

  @override
  String get chatGroupName => 'Nombre del grupo de chat';

  @override
  String get headline => 'Titular';

  @override
  String get description => 'Descripción';

  @override
  String get validityVisibilitySettings =>
      'Configuración de validez y visibilidad';

  @override
  String get searchableAtMeetingPlace =>
      'Se puede buscar en meetingplace.world';

  @override
  String get searchableHelperText =>
      'Cuando se selecciona, los detalles que comparta en esta oferta se podrán buscar públicamente en meetingplace.world';

  @override
  String get setExpiry => 'Establecer caducidad';

  @override
  String get setExpiryHelperEnabled =>
      'La invitación caducará en la fecha y hora especificadas';

  @override
  String get setExpiryHelperDisabled =>
      'La invitación seguirá siendo válida hasta que se elimine y no caducará';

  @override
  String expiresAt(String date, String time) {
    return 'Expira: $date a las $time';
  }

  @override
  String get scanCustomMediatorQrCode =>
      'Escanear el código QR del servidor de mensajes personalizado';

  @override
  String get chooseMediatorHelper =>
      'Elija qué servidor de mensajes usar para sus conexiones. Puede agregar servidores de mensajes personalizados escaneando su código QR.';

  @override
  String get setMediatorName => 'Establecer el nombre del servidor de mensajes';

  @override
  String newConnectionOptionTitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Compartir código QR directamente',
      'scanQRCode': 'Escanear código QR directamente',
      'claimAnOffer': 'Aceptar invitación al lugar de reunión',
      'publishAnOffer': 'Publicar invitación al lugar de reunión',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get setExpiryDateTime => 'Establecer fecha y hora de caducidad';

  @override
  String get selectExpiryHelperText =>
      'Selecciona cuándo debe caducar esta oferta';

  @override
  String get changeButton => 'Cambio';

  @override
  String get limitNumberOfUses => 'Limitar el número de usos';

  @override
  String get limitUsesHelperEnabled =>
      'La invitación solo se puede usar tantas veces';

  @override
  String get limitUsesHelperDisabled =>
      'La invitación se puede utilizar un número ilimitado de veces';

  @override
  String canBeUsedTimes(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Se puede usar $amount veces',
      one: 'Se puede usar solo una vez',
    );
    return '$_temp0';
  }

  @override
  String newConnectionOptionSubtitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Te ofrece privacidad y confidencialidad completas',
      'scanQRCode': 'Escanea un código QR con tu cámara',
      'claimAnOffer': 'Conéctate con alguien a través de Meeting Place',
      'publishAnOffer':
          'Publicita tu invitación para conectar en Meeting Place',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get unableToDetectCamera => 'No se puede detectar una cámara';

  @override
  String get newConnectionsOptionsHeader =>
      'Seleccione una opción para crear una nueva conexión';

  @override
  String get oobQrPresentInvitationMessage =>
      'Muestre este código QR con alguien para establecer una conexión';

  @override
  String get connectionsNowConnected => 'Ahora está conectado con';

  @override
  String get connectionsPanelOobFailedTitle => 'Error en la creación del canal';

  @override
  String get connectionsPanelOobFailedBody =>
      'No se puede establecer la conexión. Por favor, inténtalo de nuevo.';

  @override
  String connectionsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Todas',
      'offers': 'Ofertas',
      'claims': 'Reclamaciones',
      'complete': 'Completado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnections => 'No hay conexiones en esta vista';

  @override
  String connectionDeleteHeading(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Eliminar invitaciones',
      one: 'Eliminar invitación',
    );
    return '$_temp0';
  }

  @override
  String get selectMaxUsagesHelperText =>
      'Seleccione cuántas veces se puede usar esta oferta';

  @override
  String get mediator => 'Servidor de mensajes';

  @override
  String get mediatorHelperText =>
      'Este es el servidor de mensajes que se utilizará para la comunicación con cualquier contacto que se conecte a través de esta oferta';

  @override
  String get errorLoadingMediator => 'Error al cargar el servidor de mensajes';

  @override
  String get publishToMeetingPlace => 'Publicar en el lugar de reunión';

  @override
  String connectWithFirstName(String firstName) {
    return '¡Conéctate con $firstName!';
  }

  @override
  String firstNameChatGroup(String firstName) {
    return '${firstName}grupo de chat';
  }

  @override
  String get passphraseDescription =>
      '¡Conéctate conmigo usando Meeting Place!';

  @override
  String get headlineRequired => 'Se requiere título';

  @override
  String get descriptionRequired => 'Se requiere descripción';

  @override
  String get customPhraseRequired =>
      'Se requiere una frase personalizada cuando no se usa una frase aleatoria';

  @override
  String get expiryDateRequired =>
      'La fecha de caducidad es necesaria cuando la caducidad está habilitada';

  @override
  String get expiryDateFuture => 'La fecha de caducidad debe ser futura';

  @override
  String get maxUsagesGreaterThanZero =>
      'Los usos máximos deben ser mayores que 0';

  @override
  String failedToPublishOffer(String error) {
    return 'No se pudo publicar la invitación: $error';
  }

  @override
  String get selectMediator => 'Seleccione Servidor de mensajes';

  @override
  String connectionDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other:
          '¿Está seguro de que desea eliminar $amount invitaciones seleccionadas? ¡No puede deshacer la eliminación de las invitaciones!',
      one:
          '¿Está seguro de que desea eliminar esta invitación? ¡No puede deshacer la eliminación de una invitación!',
      zero:
          '¿Está seguro de que desea eliminar esta invitación? ¡No puede deshacer la eliminación de una invitación!',
    );
    return '$_temp0';
  }

  @override
  String get generalCancel => 'Cancelar';

  @override
  String get generalDelete => 'BORRAR';

  @override
  String get generalSave => 'Guardar';

  @override
  String get generalDone => 'Hecho';

  @override
  String get connectionsPanelSubtitle =>
      'Desliza y toca para administrar tus invitaciones.';

  @override
  String get findPersonAiBusinessDescription =>
      'Para conectarse con una persona o un agente de IA en Meeting Place, ingrese la frase de conexión que ha compartido con usted.';

  @override
  String get enterPassphrase => 'Introducir frase de contraseña';

  @override
  String get claimOfferTitle => 'Encuentra una invitación en Meeting Place';

  @override
  String get generalSearch => 'Buscar';

  @override
  String get generalConnect => 'Conectar';

  @override
  String contactCardFieldName(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'firstName': 'Nombre',
      'lastName': 'Apellido',
      'email': 'Correo electrónico',
      'mobile': 'Móvil',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offerDetailsHeader => 'Información de mi invitación';

  @override
  String get acceptOfferTitle => 'Detalles de la solicitud de invitación';

  @override
  String get offerDetailsDescription =>
      '¡Conéctate conmigo usando Meeting Place!';

  @override
  String get errorOwnerCannotClaimOffer =>
      'No puedes reclamar esta invitación porque eres el propietario';

  @override
  String get aliasPickerTitle => 'Conexión con esta identidad seleccionada';

  @override
  String get aliasPickerDescription =>
      'Las identidades lo ayudan a mantener su información personal privada y bajo su control. Puede optar por utilizar el alias de identidad principal que ha configurado o seleccionar uno de sus alias de identidad adicionales para esta invitación.';

  @override
  String error(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'connection_offer_owned_by_claiming_party':
          '¡No puedes aceptar esta invitación porque eres el invitador!',
      'connection_offer_already_claimed_by_claiming_party':
          'No puedes aceptar esta invitación porque ya solicitaste conectarte y tienes una reclamación pendiente en curso',
      'missingMnemonic':
          'Por favor, introduce una frase de invitación para buscar',
      'connection_offer_not_found_error':
          'Los detalles que proporcionaste no coinciden con ninguna invitación activa.',
      'discovery_register_offer_group_generic':
          'Error al publicar la invitación.',
      'missingDeviceToken':
          'No se pudo encontrar el token de notificación del dispositivo',
      'offerOwnedByClaimingParty':
          'No puedes reclamar esta invitación porque eres el propietario',
      'offerAlreadyClaimedByParty':
          'No puedes reclamar esta oferta porque ya aceptaste la invitación y tienes una solicitud pendiente en curso',
      'offerNotFound':
          'Los detalles que proporcionaste no coinciden con ninguna invitación activa.',
      'mediatorAlreadyExists':
          'Ya existe un servidor de mensajes con el mismo DID.',
      'mediator_get_did_error':
          'No se encontró un servidor de mensajes en la URL proporcionada',
      'unableToFindMediator':
          'No se encontró un servidor de mensajes en la URL proporcionada',
      'oobFlowTimedOut':
          'No se pudo establecer una conexión con la otra parte, probablemente el código QR ya fue usado',
      'connection_offer_expired': 'Esta invitación ha expirado',
      'connection_offer_limit_exceeded':
          'Esta invitación ha alcanzado su número máximo de usos',
      'register_offer_mnemonic_in_use':
          'Esta frase ya está en uso, por favor elige otra',
      'invalidQrCode': 'El código QR no es válido',
      'oob_invalid_data': 'Los datos del código QR no son válidos',
      'oob_not_found':
          'Los datos del código QR no coinciden con ninguna invitación activa',
      'oob_invalid_type': 'Los datos del código QR no son compatibles',
      'network_error':
          'No se pudo conectar. Verifica tu conexión a internet y vuelve a intentarlo.',
      'other': '$errorCode',
    });
    return '$_temp0';
  }

  @override
  String get offerCreated => 'Invitación creada';

  @override
  String offerExpiresAt(String formattedExpiry) {
    return 'La invitación vence a las $formattedExpiry';
  }

  @override
  String get offerValidityNote =>
      'La invitación es válida hasta la fecha y hora anteriores, a menos que se alcance un número máximo de accesos';

  @override
  String get offerUnlimitedUsages =>
      'Esta invitación se puede utilizar cualquier número de veces';

  @override
  String offerMaxUsages(int maxUsages) {
    String _temp0 = intl.Intl.pluralLogic(
      maxUsages,
      locale: localeName,
      other: 'Esta invitación puede usarse $maxUsages veces',
      one: 'Esta invitación puede usarse 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get noExpirySetHelperText =>
      'No se ha establecido una fecha de caducidad, por lo que esta invitación a conectarse no caduca';

  @override
  String get validityVisibilityDetails => 'Detalles de validez y visibilidad';

  @override
  String get personalInformationShared => 'Información personal compartida';

  @override
  String get myAliasProfile => 'Mi perfil de alias';

  @override
  String get didInformation => 'Información DID';

  @override
  String didSha256(String didSha256) {
    return '$didSha256 (SHA256)';
  }

  @override
  String get offerUsesPrimaryIdentity =>
      'Esta invitación utiliza tu identidad principal';

  @override
  String offerUsesAliasIdentity(String alias) {
    return 'Esta invitación utiliza el alias de identidad llamado \"$alias\"';
  }

  @override
  String get aliasProfileDescription =>
      'Tu perfil de alias te ayuda a mantener tu identidad privada y bajo tu control.';

  @override
  String get generalOk => 'DE ACUERDO';

  @override
  String get contactsPanelSubtitle =>
      'Toca un contacto para chatear, toca dos veces para ver los detalles, toca y mantén presionado para eliminar.';

  @override
  String contactsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'any': 'Cualquiera',
      'person': 'Persona',
      'group': 'Grupo',
      'service': 'Agente de IA',
      'business': 'Negocio',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noContactsYet => 'No hay contactos en esta vista';

  @override
  String get contactDeleteHeading => 'Eliminar contacto';

  @override
  String contactDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other:
          '¿Está seguro de que desea eliminar los $amount canales seleccionados?',
      one: '¿Está seguro de que desea eliminar este canal?',
      zero: '¿Está seguro de que desea eliminar este canal?',
    );
    return '$_temp0';
  }

  @override
  String connectedVia(String mediatorName) {
    return 'Conectado a través de $mediatorName';
  }

  @override
  String contactAdded(String dateAdded) {
    return 'Añadido $dateAdded';
  }

  @override
  String get filter => 'Filtro...';

  @override
  String get noContactsMatchFilter =>
      'No hay contactos que coincidan con tu filtro';

  @override
  String connectionPhrase(String phrase) {
    return 'Frase: $phrase';
  }

  @override
  String usesIdentityViaMediator(String identity, String mediator) {
    return 'Utiliza su identidad $identity a través de $mediator';
  }

  @override
  String usesIdentity(String identity) {
    return 'Usa tu identidad $identity para conectar';
  }

  @override
  String get timeAgoJustNow => 'Justo ahora';

  @override
  String timeAgoMinute(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'hace $minutes minutos',
      one: 'hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoMinuteWorded => 'Hace un minuto';

  @override
  String timeAgoHourNumeric(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'hace $hours horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoHourWorded => 'Hace una hora';

  @override
  String timeAgoDay(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoYesterday => 'Ayer';

  @override
  String timeAgoWeek(num weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'hace $weeks semanas',
      one: 'hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoLastWeek => 'La semana pasada';

  @override
  String timeAgoSecond(num seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'hace $seconds segundos',
      one: 'hace 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String createdValidUntil(String createdTimeAgo, String validUntilDate) {
    return 'Creado $createdTimeAgo, válido hasta $validUntilDate';
  }

  @override
  String createdValidWithoutExpiration(String createdTimeAgo) {
    return 'Creado $createdTimeAgo, sin fecha de caducidad';
  }

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get generalName => 'Nombre';

  @override
  String get displayNameHelperText =>
      'Puede cambiar el nombre para mostrar de este contacto. La otra parte no verá este nombre.';

  @override
  String get generalDid => '¿LO HUDÓ?';

  @override
  String get generalDidSha256 => 'TID (SHA256)';

  @override
  String get connectionEstablished => 'Canal establecido';

  @override
  String get generalMediator => 'Servidor de mensajes';

  @override
  String get connectionApproach => 'Enfoque de establecimiento de canales';

  @override
  String get theirDetails => 'Sus detalles';

  @override
  String get mySharedIdentityDetails => 'Mis datos de identidad compartidos';

  @override
  String get connectionDetails => 'Detalles de conexión de canal';

  @override
  String get myIdentity => 'Mi identidad';

  @override
  String get identitiesPanelSubtitle =>
      'Desliza el dedo hacia la izquierda y hacia la derecha para revisar y agregar a tu lista de identidades, arrastra hacia abajo para eliminar ';

  @override
  String identitiesFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Todos',
      'primary': 'Primario',
      'aliases': 'Alias',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get identityDeleteHeading => 'Eliminar identidad';

  @override
  String identityDeletePrompt(Object identity) {
    return '¿Está seguro de que desea eliminar la identidad \"$identity\"?\n\n¡No puedes recuperar una identidad!';
  }

  @override
  String get displayNamePrimary => 'Identidad primaria';

  @override
  String get displayNameAddNew => 'Agregar nueva identidad';

  @override
  String get displayNameAlias => 'Alias de identidad';

  @override
  String get subtitlePrimary => 'Su identidad principal';

  @override
  String get subtitleAddNew => 'Crear un nuevo alias';

  @override
  String get subtitleAlias => 'Identidad de alias';

  @override
  String get notShared => 'No compartido';

  @override
  String get unknownUser => 'Usuario desconocido';

  @override
  String get unnamed => 'Sin nombre';

  @override
  String get unnamedMediator => 'Usuario desconocido';

  @override
  String get addNewIdentityAlias => 'Agregar nuevo alias de identidad';

  @override
  String get identityAliasesDescription =>
      'Toma el control de tu privacidad, creando alias de identidad para representarte a ti mismo ante los contactos con los que te conectas';

  @override
  String get generalReject => 'RECHAZAR';

  @override
  String get generalApprove => 'APROBAR';

  @override
  String get zalgoTextDetectedError =>
      'Personajes inusuales detectados. Por favor, elimínelos e inténtelo de nuevo.';

  @override
  String get chatTooLong => 'El mensaje de chat es demasiado largo';

  @override
  String get splashScreenTitle => 'Lugar de encuentro';

  @override
  String get toProtectData =>
      'Para proteger sus datos, esta aplicación requiere una autenticación segura para continuar.';

  @override
  String get authInstructionAndroid =>
      'Ve a Configuración > Seguridad > Bloqueo de pantalla y habilita un PIN, un patrón o una huella digital.';

  @override
  String get authInstructionIos =>
      'Ve a Configuración > Face ID y código de acceso (o Touch ID y código de acceso) y configura Face ID, Touch ID o un código de acceso del dispositivo.';

  @override
  String get authInstructionMacos =>
      'Ve a Configuración del sistema > Touch ID y contraseña (o contraseña de inicio de sesión) y configura Touch ID o una contraseña segura.';

  @override
  String get authUnlockReason => 'Desbloquea tu dispositivo para continuar';

  @override
  String chatTypeMessagePrompt(String name) {
    return 'Mensaje para $name';
  }

  @override
  String get chatAddMessageToMediaPrompt => 'Agregar un mensaje';

  @override
  String get chatTypeMessagePromptGroup => 'Mensaje al canal';

  @override
  String get updatePrimaryIdentity => 'Actualización de la identidad principal';

  @override
  String get newIdentityAlias => 'Nuevo alias de identidad';

  @override
  String editIdentityTitle(String identityName) {
    return 'Editar identidad: $identityName';
  }

  @override
  String get customiseIdentityCard => 'Personaliza el documento de identidad';

  @override
  String get nameTooLong => 'El nombre es demasiado largo';

  @override
  String get descriptionTooLong => 'La descripción es demasiado larga';

  @override
  String get invalidEmail => 'La dirección de correo electrónico no es válida';

  @override
  String get emailTooLong =>
      'La dirección de correo electrónico es demasiado larga';

  @override
  String get invalidMobileNumber => 'El número de teléfono móvil no es válido';

  @override
  String get mobileTooLong => 'El número de móvil es demasiado largo';

  @override
  String get aliasTooLong => 'El alias es demasiado largo';

  @override
  String get thisFieldIsRequired => 'Este campo es obligatorio';

  @override
  String get identityAliasPersonalDetails =>
      'Datos personales de alias de identidad';

  @override
  String get profilePictureChangePrompt =>
      'Pulsa aquí para cambiar tu foto de perfil';

  @override
  String get enterFirstName => 'Ingrese el nombre';

  @override
  String get enterLastName => 'Ingrese el apellido';

  @override
  String get enterEmail => 'Ingrese el correo electrónico';

  @override
  String get enterMobile => 'Ingrese al móvil';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get aliasLabel => 'Etiqueta de alias';

  @override
  String get enterAliasLabel => 'Introduzca la etiqueta de alias';

  @override
  String get aliasLabelHelperText =>
      'La etiqueta de alias es la forma en que se referirá a este alias cuando se conecte. Use un nombre descriptivo para que sea más fácil de identificar.';

  @override
  String get setupPrimaryIdentityTitle =>
      '¡Configuremos tu identidad principal!';

  @override
  String get setupPrimaryIdentityDescription =>
      'Tu identidad principal se utilizará de forma predeterminada cuando te conectes con otras personas.';

  @override
  String get primaryIdentityInformation =>
      'Su información de identidad principal';

  @override
  String get primaryIdentityComplete => 'Mi identidad principal está completa';

  @override
  String get keepMeAnonymous => 'Mantenme en el anonimato';

  @override
  String typingMessage(String names, int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$names están escribiendo',
      one: '$names está escribiendo',
    );
    return '$_temp0';
  }

  @override
  String awaitingMembersToJoin(String names, int namesCount, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount más',
      one: '1 más',
    );
    String _temp1 = intl.Intl.pluralLogic(
      namesCount,
      locale: localeName,
      other: 'Esperando a que se unan $names y $_temp0',
      one: 'Esperando a que se una $names',
    );
    return '$_temp1';
  }

  @override
  String get unknownType => 'Tipo desconocido';

  @override
  String get loadImageFailed => 'Error al cargar la imagen';

  @override
  String get chatRequestPermissionToJoinGroupFailed =>
      'No se pudo unir al grupo';

  @override
  String get genWordConciergeMessage => 'Mensaje de conserjería';

  @override
  String chatRequestPermissionToJoinGroup(String memberName) {
    return '$memberName quiere unirse al grupo';
  }

  @override
  String get chatEncryptionNotice =>
      'Los mensajes y cualquier dato compartido en este chat están cifrados de extremo a extremo. Solo las personas y agentes de este chat pueden leerlos.';

  @override
  String get genWordNo => 'No';

  @override
  String get genWordLater => 'Más tarde';

  @override
  String get genWordYes => 'Sí';

  @override
  String get chatRequestPermissionToUpdateProfileGroup =>
      'Los detalles del perfil compartidos con este grupo han cambiado. ¿Le gustaría actualizar a todos los miembros?';

  @override
  String get chatRequestPermissionToUpdateProfile =>
      'Los detalles del perfil compartidos con este contacto han cambiado. ¿Te gustaría enviarles una actualización?';

  @override
  String chatStartOfConversationInitiatedByMe(String date, String time) {
    return 'Estableciste este canal en $date en $time';
  }

  @override
  String get messageCopiedClipboard => 'Mensaje copiado en el portapapeles';

  @override
  String get chatMessageActionDelete => 'Eliminar para todos';

  @override
  String get chatMessageActionDeleteLocal => 'Eliminar para mí';

  @override
  String get chatMessageActionCopy => 'Copiar mensaje';

  @override
  String get chatMessageActionEdit => 'Editar mensaje';

  @override
  String get chatMessageEditedLabel => 'editado';

  @override
  String get chatMessageEditFailed => 'No se pudo editar el mensaje';

  @override
  String get chatMessageEditHint => 'Texto del mensaje';

  @override
  String get chatMessageEditSave => 'Guardar';

  @override
  String get chatMessageDeletedTombstone => 'Este mensaje fue eliminado';

  @override
  String get chatMessageDeletedLocallyTombstone => 'Eliminaste este mensaje';

  @override
  String get chatMessageDeleteFailed => 'No se pudo eliminar el mensaje';

  @override
  String chatItemStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'queued': 'En cola',
      'delivered': 'Entregado',
      'sending': 'Enviando',
      'sent': 'Enviado',
      'error': 'Error',
      'groupDeleted': 'Grupo eliminado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get qrScannerTitle => 'Escanear código QR';

  @override
  String get qrScannerInstructions => 'Coloca el código QR dentro del marco';

  @override
  String qrScannerStatus(String status) {
    return 'Estado del escáner: $status';
  }

  @override
  String get useCamera => 'Usar cámara';

  @override
  String get chooseFromGallery => 'Elige de la galería';

  @override
  String get qrScannerCameraPermissionHelp =>
      'Verifique los permisos de la cámara e inténtelo de nuevo';

  @override
  String get qrScannerConnectionFailed => 'Error de conexión';

  @override
  String qrScannerConnectionFailedMessage(String error) {
    return 'No se pudo establecer la conexión: $error';
  }

  @override
  String get qrScannerTryAgain => 'Vuelve a intentarlo';

  @override
  String get qrScannerTimeoutError =>
      'Se agotó el tiempo de espera de aceptación del flujo OOB después de 30 segundos';

  @override
  String get customMediators => 'Servidores de mensajes personalizados';

  @override
  String get addCustomMediator => 'Agregar servidor de mensajes personalizado';

  @override
  String get manageCustomMediators =>
      'Administrar el servidor de mensajes personalizados';

  @override
  String get configureCustomMediatorEndpoint =>
      'Configurar su propio punto de conexión del servidor de mensajes';

  @override
  String get noCustomMediatorsConfigured =>
      'Aún no hay servidores de mensajes personalizados configurados';

  @override
  String customMediatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servidores de mensajes personalizados configurados',
      one: '1 servidor de mensajes personalizados configurado',
    );
    return '$_temp0';
  }

  @override
  String addedMediatorSuccess(String name) {
    return 'Añadido servidor de mensajes \"$name\"';
  }

  @override
  String failedToAddMediator(String error) {
    return 'No se pudo agregar el servidor de mensajes: $error';
  }

  @override
  String get mediatorName => 'Nombre del servidor de mensajes';

  @override
  String get mediatorDid => 'Servidor de mensajes DID';

  @override
  String get myCustomMediator => 'Mi servidor de mensajes personalizado';

  @override
  String get pleaseEnterName => 'Por favor, introduzca un nombre';

  @override
  String get pleaseEnterDid => 'Por favor, introduzca un DID';

  @override
  String get didMustStartWith => 'DID debe comenzar con \"did:\"';

  @override
  String get deleteCustomMediator =>
      'Eliminar servidor de mensajes personalizados';

  @override
  String deleteCustomMediatorConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String deletedMediatorSuccess(String name) {
    return 'Servidor de mensajes eliminados \"$name\"';
  }

  @override
  String renamedMediatorSuccess(String name) {
    return 'Se ha cambiado el nombre del servidor de mensajes a \"$name\"';
  }

  @override
  String failedToDeleteMediator(String error) {
    return 'No se pudo eliminar el servidor de mensajes: $error';
  }

  @override
  String failedToRenameMediator(String error) {
    return 'No se pudo cambiar el nombre del servidor de mensajes: $error';
  }

  @override
  String get generalRetry => 'Reintentar';

  @override
  String get generalClose => 'Cerrar';

  @override
  String get generalAdd => 'Agregar';

  @override
  String get noIdentityDetected =>
      'No se detectó ninguna identidad, cree una para continuar.';

  @override
  String get connectWithPersonAiServiceBusiness =>
      'Conéctese con una persona o un agente de IA';

  @override
  String get chatScreenTapForMemberDetails =>
      'Toque para obtener los detalles del miembro';

  @override
  String get debugPanelTitle => 'Panel de depuración';

  @override
  String get debugPanelSubtitle =>
      'Ver registros de aplicaciones e información de depuración';

  @override
  String get debugPanelNoLogs => 'No hay registros disponibles';

  @override
  String get debugPanelLogsAppearMessage =>
      'Los registros aparecerán aquí a medida que use la aplicación';

  @override
  String get debugPanelClearLogs => 'Borrar registros';

  @override
  String get debugPanelCopyLogs => 'Copiar registros en el portapapeles';

  @override
  String get debugPanelAddTestLog => 'Agregar registro de pruebas';

  @override
  String get debugPanelLogsCopied => 'Registros copiados en el portapapeles';

  @override
  String get debugPanelShareLogs => 'Compartir registros';

  @override
  String get serverSettings => 'Configuración del servidor';

  @override
  String get serverSettingsHelperText =>
      'Seleccione el servidor predeterminado para la comunicación de mensajería';

  @override
  String get debugSettingsTitle => 'Configuración de depuración';

  @override
  String get debugModeLabel => 'Modo de depuración';

  @override
  String debugModeHelperText(int tapCount) {
    return 'El modo de depuración está habilitado. Toca información de la versión $tapCount veces para alternar.';
  }

  @override
  String get settingsScreenSubtitle =>
      'Configurar los ajustes y preferencias de la aplicación';

  @override
  String get versionInfoHeader => 'Versión del lugar de reunión';

  @override
  String versionInfoVersion(String version) {
    return 'Versión $version';
  }

  @override
  String versionInfoBuild(String buildNumber) {
    return 'Construcción: $buildNumber';
  }

  @override
  String get easterEggEnabled =>
      '🎉 ¡Huevo de Pascua desbloqueado! Modo de depuración habilitado';

  @override
  String get debugModeDisabled => 'Modo de depuración deshabilitado';

  @override
  String get generalCamera => 'Cámara';

  @override
  String get switchCamera => 'Cambiar cámara';

  @override
  String get generalPhoto => 'Foto';

  @override
  String get generalBalloons => 'Globos';

  @override
  String get generalConfetti => 'Confeti';

  @override
  String get chatItemStatusError => 'Error';

  @override
  String get formValidationHeadlineRequired => 'Se requiere título';

  @override
  String get formValidationDescriptionRequired => 'Se requiere descripción';

  @override
  String get formValidationCustomPhraseRequired =>
      'Se requiere una frase personalizada cuando no se usa una frase aleatoria';

  @override
  String get formValidationExpiryDateRequired =>
      'La fecha de caducidad es necesaria cuando la caducidad está habilitada';

  @override
  String get formValidationExpiryDateFuture =>
      'La fecha de caducidad debe ser futura';

  @override
  String get formValidationMaxUsagesGreaterThanZero =>
      'Los usos máximos deben ser mayores que 0';

  @override
  String get genericPublishError => 'No se pudo publicar la oferta';

  @override
  String get groupDetails => 'Detalles del canal de grupo';

  @override
  String groupMessageInfo(String memberName, String date, String time) {
    return '$memberName en $date en $time';
  }

  @override
  String contactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Pendiente de Aprobación',
      'pendingInauguration': 'Estableciendo Conexión',
      'approved': 'Contacto Activo',
      'rejected': 'Rechazado',
      'error': 'Error',
      'deleted': 'Eliminado',
      'active': 'Canal Activo',
      'unknown': 'Desconocido',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String groupContactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Aprobación Pendiente',
      'pendingInauguration': 'Estableciendo Canal',
      'approved': 'Canal de Grupo Activo',
      'rejected': 'Rechazado',
      'error': 'Error',
      'deleted': 'Eliminado',
      'active': 'Canal de Grupo Activo',
      'unknown': 'Desconocido',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String contactOrigin(String origin) {
    String _temp0 = intl.Intl.selectLogic(origin, {
      'directInteractive': 'Interacción Directa',
      'individualOfferPublished': 'Invitación a Lugar de Encuentro Ofrecida',
      'individualOfferRequested': 'Invitación a Lugar de Encuentro Aceptada',
      'groupOfferPublished':
          'Invitación de Grupo a Lugar de Encuentro Ofrecida',
      'groupOfferRequested':
          'Invitación de Grupo a Lugar de Encuentro Aceptada',
      'unknown': 'Desconocido',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String get groupMembers => 'Miembros del grupo';

  @override
  String get showExited => 'Mostrar salido';

  @override
  String get groupMemberExited => 'Salió del grupo';

  @override
  String get groupNoMembersToChat =>
      'Actualmente eres el único miembro de este grupo. Puede comenzar a chatear cuando otro miembro se una.';

  @override
  String get generalJoined => 'Unido';

  @override
  String get you => 'Tú';

  @override
  String get groupAdmin => 'Administrador de grupos';

  @override
  String get onboardingPage1Title => 'Bienvenidos a\nLugar de encuentro';

  @override
  String get onboardingPage1Desc => 'Funciona con\nMensajería de Affinidi';

  @override
  String get onboardingPage2Title => 'Privado y seguro';

  @override
  String get onboardingPage2Desc =>
      'Conéctese con otras personas de forma segura y privada con cifrado de extremo a extremo';

  @override
  String get onboardingPage3Title => 'Toma el control de tu identidad';

  @override
  String get onboardingPage3Desc =>
      'Protege tu privacidad con alias. Demuestra tu identidad con credenciales verificadas';

  @override
  String get onboardingPage4Title => 'Listo para empezar';

  @override
  String get onboardingPage4Desc =>
      'Configuremos tu identidad\n¡y te ayudaré a comenzar!';

  @override
  String get setUpMyIdentity => 'Configurar mi identidad';

  @override
  String get revealConnectionCode =>
      'Revelar frase de contraseña de invitación';

  @override
  String versionInfoAppName(String appName) {
    return 'Meeting Place \"$appName\"';
  }

  @override
  String get platformNotSupported =>
      'Este plugin no es compatible con tu plataforma actual';

  @override
  String get generalOfferInformation => 'Información sobre la invitación';

  @override
  String get generalOfferLink => 'Enlace de invitación';

  @override
  String get generalMnemonic => 'Mnemotécnico';

  @override
  String get generalConnectionType => 'Tipo de conexión';

  @override
  String get generalExternalRef => 'Referencia externa';

  @override
  String get generalGroupDid => 'Grupo DID';

  @override
  String get generalGroupId => 'ID de grupo';

  @override
  String get copiedToClipboard => 'Copiado en el portapapeles';

  @override
  String connectionStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'published': 'Creado',
      'finalised': 'Completado',
      'accepted': 'Esperando',
      'channelInaugurated': 'Activo',
      'deleted': 'Eliminado',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String get publishing => 'Publicando';

  @override
  String get loading => 'Cargando';

  @override
  String get deleting => 'Eliminando';

  @override
  String get showQrScannerForOffers => 'Mostrar escáner QR para invitaciones';

  @override
  String get meetingPlaceControlPlane =>
      'Plano de control del lugar de reunión';

  @override
  String get searching => 'Minucioso';

  @override
  String get connecting => 'Conectivo';

  @override
  String get approving => 'Aprobatorio';

  @override
  String get rejecting => 'RECHAZAR';

  @override
  String get sending => 'Envío';

  @override
  String get connectionRequestRejected =>
      'La solicitud de conexión ha sido rechazada';

  @override
  String get connectionRequestInProgress =>
      'Aceptación de invitación en curso. La otra parte puede tardar unos minutos en responder y finalizar el canal.';

  @override
  String requestToConnect(Object firstName) {
    return 'La aceptación de la invitación se ha enviado $firstName. Es posible que tarden unos minutos en responder a su solicitud.';
  }

  @override
  String contactsDeleted(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Canales eliminados',
      one: 'Canal eliminado',
    );
    return '$_temp0';
  }

  @override
  String joiningGroup(String memberName) {
    return '$memberName se ha unido al grupo';
  }

  @override
  String leavingGroup(String memberName) {
    return '$memberName ha dejado el grupo';
  }

  @override
  String memberRemovedFromGroup(String memberName) {
    return '$memberName ha sido eliminado';
  }

  @override
  String get concierge => 'Conserje';

  @override
  String get groupDeleted => 'Este grupo ha sido eliminado';

  @override
  String get creatingConnection => 'Creando conexión...';

  @override
  String get generatingQrCode => 'Generando tu código QR';

  @override
  String get processing => 'Procesando...';

  @override
  String oobConnectedTo(String memberName) {
    return '¡Ahora estás conectado con $memberName!';
  }

  @override
  String get oobChatTo => 'Charlar';

  @override
  String get networkDisconnected => 'No estás conectado a la red';

  @override
  String get chatNotificationsUnavailable =>
      'Las notificaciones de chat no están disponibles para conexiones directas';

  @override
  String get chatNotificationsUnavailableNotShared =>
      'Las notificaciones para este canal de chat no están disponibles';

  @override
  String get chatNotificationsWhyTitle =>
      '¿Por qué no hay notificaciones push?';

  @override
  String get chatNotificationsWhyDescription =>
      'Cuando estableces una conexión mediante escaneo directo o compartiendo un código QR, tus dispositivos se conectan directamente sin intercambiar tokens de notificación con nuestros servidores. Esto significa que no se pueden enviar notificaciones push cuando el chat está cerrado.';

  @override
  String get chatNotificationsWhyNote =>
      'Solo verás mensajes nuevos cuando estés en el chat. No habrá actualizaciones de insignias ni notificaciones que te informen que han llegado mensajes nuevos, incluso si la aplicación está abierta.';

  @override
  String get chatNotificationsWhyButton => 'Entendido';

  @override
  String get chatNotificationsWhyLink => '¿Por qué?';

  @override
  String get meetingPlaceInvitationTitle => 'Invitación al lugar de encuentro';

  @override
  String get shareSheetCTA_QRCode => 'Enviar o guardar código QR';

  @override
  String get cameraInstructionAndroid =>
      'Toca \"Abrir configuración\" abajo para habilitar el acceso a la cámara. Si eso no funciona, abre Configuración manualmente:\n\nConfiguración > Aplicaciones > Meeting Place > Permisos > Cámara > Permitir solo mientras se usa la aplicación.';

  @override
  String get cameraInstructionIos =>
      'Toca \"Abrir Configuración\" abajo para habilitar el acceso a la cámara. Si eso no funciona, abre Configuración manualmente:\n\nConfiguración > Meeting Place > Cámara y habilita el acceso para esta aplicación.';

  @override
  String get cameraInstructionMacos =>
      'Ve a Configuración del sistema > Privacidad y seguridad > Cámara y permite el acceso a la cámara para esta aplicación.';

  @override
  String get cameraAccessDenied =>
      'Acceso a la cámara denegado o no disponible.';

  @override
  String get cameraOpenSettings => 'Abrir configuración';

  @override
  String get cameraNotAvailable => 'Cámara no disponible';

  @override
  String get goBack => 'Volver';

  @override
  String get rCardsPanelSubtitle =>
      'Tarjetas de relación recibidas de tus contactos';

  @override
  String get rCardsEmpty =>
      'Las tarjetas R son una versión moderna y autoactualizante de las vCards. Una vez que hagas tu primera conexión, tus tarjetas de visita digitales aparecerán aquí.';

  @override
  String rCardsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Todos',
      'nonAnonymous': 'No anónimos',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noRCardsFoundWithFilter =>
      'No se encontraron tarjetas R que coincidan con tu búsqueda.';

  @override
  String get rCardDetailsTitle => 'Detalles de la Tarjeta R';

  @override
  String get rCardSectionIdentity => 'Identidad';

  @override
  String get rCardSectionMetadata => 'Detalles de Credencial';

  @override
  String get rCardFieldName => 'Nombre';

  @override
  String get rCardFieldEmail => 'Correo electrónico';

  @override
  String get rCardFieldPhone => 'Teléfono';

  @override
  String get rCardFieldCompany => 'Empresa';

  @override
  String get rCardFieldPosition => 'Puesto';

  @override
  String get rCardFieldWebsite => 'Sitio web';

  @override
  String get rCardFieldSocial => 'Social';

  @override
  String get rCardFieldSubjectDid => 'DID del sujeto';

  @override
  String get rCardAddNotes => 'Añadir notas';

  @override
  String get rCardUpdateNotes => 'Actualizar notas';

  @override
  String get rCardNotesTitle => 'Notas';

  @override
  String get rCardNotesPlaceholder => 'Escribe tus notas aquí...';

  @override
  String get rCardDeletePrompt =>
      '¿Estás seguro de que quieres eliminar esta Tarjeta R? Esta acción no se puede deshacer.';

  @override
  String rCardChatWith(String name) {
    return 'Chat con $name';
  }

  @override
  String get removeMemberDialogTitle => 'Eliminar miembro';

  @override
  String removeMemberDialogBody(String name) {
    return '¿Eliminar a $name de este grupo? Ya no recibirá mensajes.';
  }

  @override
  String get rCardFieldIssuerDid => 'DID del emisor';

  @override
  String get rCardFieldReceivedAt => 'Recibido';

  @override
  String get rCardFieldIssuedAt => 'Emitido';

  @override
  String get rCardTitle => 'Tarjeta R';

  @override
  String get verifiableCredential => 'Credencial verificable';

  @override
  String get verified => 'Verificado';

  @override
  String get verifiableCredentialDescription =>
      'Credenciales digitales seguras que pueden verificarse para comprobar su autenticidad';

  @override
  String get secureAttachmentsTitle => 'Archivos adjuntos seguros';

  @override
  String get credentialDetails => 'Detalles de la credencial';

  @override
  String get genRCard => 'Tarjeta R';

  @override
  String get rCardPickIdentitySubtitle =>
      'Selecciona la identidad para compartir como Tarjeta R';

  @override
  String get rCardFooterSent => 'Tarjeta R enviada.';

  @override
  String get rCardFooterSaved => 'Tarjeta R guardada.';

  @override
  String get rCardFooterUpdateShared =>
      'La actualización de la tarjeta R ha sido compartida.';

  @override
  String get profileDetailsUpdateSharedGroup =>
      'La actualización de los detalles del perfil ha sido compartida con el grupo.';

  @override
  String get rCardFooterUpdateSaved =>
      'La actualización de la tarjeta R se ha guardado.';

  @override
  String get rCardsExchanged => 'Tarjetas R intercambiadas';

  @override
  String get goToRCard => 'Ir a la Tarjeta R';

  @override
  String get selectIdentityTitle => 'Seleccionar Identidad';

  @override
  String get selectIdentityInstruction =>
      'Desliza a la izquierda o derecha para elegir la identidad que deseas usar para generar la Tarjeta‑R';

  @override
  String get sendRCard => 'Enviar Tarjeta R';

  @override
  String selectIdentityToVerifyRelationshipWithName(String name) {
    return 'Selecciona la identidad que deseas usar para verificar tu relación con $name';
  }

  @override
  String get verifiableRelationshipCredential =>
      'Credencial de Relación Verificable';

  @override
  String get vrcAbbreviation => 'VRC';

  @override
  String get vrcDetailsTitle => 'Credencial de Relación';

  @override
  String get vrcSectionIssuer => 'Emisor';

  @override
  String get vrcSectionHolder => 'Emitido a';

  @override
  String get vrcSectionMetadata => 'Detalles de la Credencial';

  @override
  String get vrcFieldDid => 'DID';

  @override
  String get vrcFieldName => 'Nombre';

  @override
  String get vrcFieldIssuedAt => 'Emitido el';

  @override
  String get vrcFieldVerifiedAt => 'Verificada';

  @override
  String get vrcFieldTypes => 'Tipos';

  @override
  String get vrcDescription =>
      'Esta credencial verifica la relación entre dos partes.';

  @override
  String verifyRelationshipPrompt(String firstName) {
    return 'Verifica tu relación con $firstName emitiendo una Credencial de Relación Verificable (VRC). Cada intercambio de VRC aumenta tu puntuación de confianza.';
  }

  @override
  String get generateVrc => 'Empezar ahora';

  @override
  String get generalVerify => 'Confirmar';

  @override
  String get doLater => 'Más tarde';

  @override
  String get vrcExchangeInitiated => 'Has iniciado el intercambio de VRC.';

  @override
  String vrcRequestReceived(String name) {
    return '$name ha iniciado el intercambio de VRC.';
  }

  @override
  String get vrcDoLater =>
      'El intercambio de VRC está en pausa. Toca + y selecciona \'Credencial de Relación Verificable\' para continuar.';

  @override
  String get vrcExchangeCompleted => 'Has verificado tu relación con éxito';

  @override
  String vrcVerifyPrompt(String name) {
    return '¿Deseas verificar tu relación con $name? Cada intercambio de VRC aumenta tu puntuación de confianza.';
  }

  @override
  String get vrcStartNow => 'Comenzar ahora';

  @override
  String get vrcDoLaterButton => 'Más tarde';

  @override
  String get vrcYesButton => 'Sí';

  @override
  String nameSelectedIdentity(String name) {
    return 'Identidad seleccionada de $name';
  }

  @override
  String selectIdentityToVerifyRelationshipPrompt(String name) {
    return 'Desliza hacia la izquierda o derecha para elegir la identidad que deseas usar para verificar tu relación con $name.';
  }

  @override
  String get sendVrc => 'Enviar Credencial de Relación';

  @override
  String trustedBy(int count) {
    return 'Confiado por $count';
  }

  @override
  String get humanZkp => 'Prueba de conocimiento cero humana';

  @override
  String get humanZkpAbbreviated => 'Human ZKP';

  @override
  String get humanZeroKnowledgeProof => 'Prueba de conocimiento cero humana';

  @override
  String get livenessCredential => 'Credencial de Vitalidad';

  @override
  String get verifiableCredentialWallet =>
      'Cartera de Credenciales Verificables';

  @override
  String get noCredentialsYet => 'Aún no tienes credenciales.';

  @override
  String get membershipsTab => 'Memberships';

  @override
  String get membershipCredentialsVtaMissing =>
      'Link your VTA to see your membership cards.';

  @override
  String get membershipCredentialsUnreachable =>
      'Your VTA couldn\'t be reached, so your membership cards can\'t be shown.';

  @override
  String get membershipCredentialsSaved =>
      'Your VTA couldn\'t be reached. Showing the cards saved on this phone.';

  @override
  String get membershipCredentialsNone =>
      'No membership cards yet. Join a community to get one.';

  @override
  String get membershipCredentialUnnamed => 'A community';

  @override
  String get membershipCredentialOtherIdentity =>
      'an identity not on this phone';

  @override
  String membershipCredentialAs(String identity) {
    return 'as $identity';
  }

  @override
  String membershipCredentialUntil(String date) {
    return 'until $date';
  }

  @override
  String membershipCredentialLeft(String date) {
    return 'left $date';
  }

  @override
  String get membershipStatusChecking => 'Checking…';

  @override
  String get membershipStatusValid => 'Valid';

  @override
  String get membershipStatusRevoked => 'Revoked';

  @override
  String get membershipStatusExpired => 'Expired';

  @override
  String get membershipStatusNotRevocable => 'Can\'t be revoked';

  @override
  String get membershipStatusUnknown => 'Couldn\'t check';

  @override
  String get membershipDetailsTitle => 'Membership card';

  @override
  String get membershipOpenCommunity => 'Open community';

  @override
  String get membershipOpenWebsite => 'Visit website';

  @override
  String membershipTrailIssued(String community) {
    return 'Issued by $community';
  }

  @override
  String membershipTrailIssuedSummary(
    String identity,
    String community,
    String date,
  ) {
    return 'Your membership card for $identity, signed by $community on $date';
  }

  @override
  String membershipTrailIssuedSummaryUndated(
    String identity,
    String community,
  ) {
    return 'Your membership card for $identity, signed by $community';
  }

  @override
  String get membershipTrailMember => 'Card is for';

  @override
  String get membershipTrailValidFrom => 'Valid from';

  @override
  String get membershipTrailCardDocument => 'Your membership card';

  @override
  String get membershipTrailYourVta => 'Your VTA';

  @override
  String get membershipTrailThisPhone => 'This phone';

  @override
  String get membershipTrailKept => 'Kept on your VTA';

  @override
  String membershipTrailKeptSummary(String identity, String time) {
    return 'Your VTA holds the card for $identity · read from it at $time';
  }

  @override
  String get membershipTrailPutAway =>
      'Your VTA put the card away when you left';

  @override
  String membershipTrailLeft(String community) {
    return 'You left $community';
  }

  @override
  String membershipTrailLeftActor(String community) {
    return 'Your VTA, then $community';
  }

  @override
  String membershipTrailLeftSummary(String community, String keeps) {
    return 'Your VTA signed it as your identity · $community confirmed it and $keeps';
  }

  @override
  String get membershipTrailKeepsNothing => 'keeps nothing about you';

  @override
  String get membershipTrailKeepsNote =>
      'keeps only a note that you were a member';

  @override
  String get membershipTrailKeepsHistory => 'keeps your membership as history';

  @override
  String get membershipTrailKeepsUnknown => 'keeps what its rules say';

  @override
  String membershipTrailLeftNoReceipt(String community) {
    return '$community already counted you as no member, so there is no receipt';
  }

  @override
  String get membershipTrailLeftDocument => 'Your leave and its receipt';

  @override
  String membershipTrailChecked(String community) {
    return 'Checked with $community';
  }

  @override
  String membershipTrailCheckDirect(String community) {
    return 'This phone asked $community directly, without your VTA';
  }

  @override
  String membershipTrailChecking(String community) {
    return 'This phone is asking $community, without your VTA…';
  }

  @override
  String membershipTrailRevoked(String community, String time) {
    return '$community has revoked this card · its signed list says so, checked at $time';
  }

  @override
  String membershipTrailValid(String time) {
    return 'Still valid · checked at $time';
  }

  @override
  String membershipTrailUnreachable(String community) {
    return 'Couldn\'t reach $community';
  }

  @override
  String membershipTrailLastRevoked(String time) {
    return 'last checked at $time, it was revoked';
  }

  @override
  String membershipTrailLastValid(String time) {
    return 'last checked at $time, it was valid';
  }

  @override
  String membershipTrailNotRevocable(String community) {
    return 'This card can\'t be revoked: $community gave it no status list';
  }

  @override
  String membershipTrailExpired(String date) {
    return 'Its validity ended on $date, so it no longer holds';
  }

  @override
  String get membershipTrailCheckedNoTask =>
      'None: the community\'s status list is read over HTTPS';

  @override
  String get membershipTrailStatusList => 'Status list';

  @override
  String get membershipTrailStatusIndex => 'Place in the list';

  @override
  String get membershipTrailCheckedAt => 'Checked at';

  @override
  String membershipTrailStatusDocument(String community) {
    return '$community\'s signed status list';
  }

  @override
  String get membershipTrailStoredId => 'Kept under';

  @override
  String get membershipTrailStoredPurpose => 'Filed as';

  @override
  String get membershipTrailStoredStatus => 'Your VTA holds it as';

  @override
  String get membershipTrailStoredTypes => 'Types';

  @override
  String get membershipFlowCommunity => 'Community';

  @override
  String get all => 'Todos';

  @override
  String get generatingZeroKnowledgeProof =>
      'Generando Prueba de Conocimiento Cero Humano...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get generateCredential => 'Generar credencial';

  @override
  String get generateProof => 'Generar prueba';

  @override
  String get livenessCredentialRequest =>
      'Solicitud de credencial de detección de vida';

  @override
  String get livenessCheckDemoMode =>
      'Verificación de detección de vida (Modo Demo)';

  @override
  String get searchingForLivenessCredential =>
      'Buscando credencial de detección de vida...';

  @override
  String get noLivenessCredentialFound =>
      'No se encontró ninguna credencial de detección de vida.\n\nPara continuar, se generará localmente una credencial de detección de vida simulada.\nEsta credencial se utiliza para demostrar cómo se deriva una prueba de conocimiento cero (ZKP).';

  @override
  String get livenessCheckDemoModeNote =>
      'Esta aplicación de referencia se ejecuta en modo de demostración y no realiza una verificación de detección de vida real.';

  @override
  String get livenessCheckInProgress =>
      'Verificación de detección de vida en progreso...';

  @override
  String get livenessCheckSimulatedFlow =>
      'Este es un flujo simulado solo para fines de desarrollo y demostración.';

  @override
  String get mockLivenessCredentialGenerated =>
      'Se ha generado una credencial de detección de vida simulada y se ha almacenado de forma segura en la pestaña Credenciales.\nAhora puede continuar para generar una prueba de conocimiento cero humana.';

  @override
  String get mockLivenessCredentialNext =>
      'Ahora puedes continuar para generar una Prueba de Conocimiento Cero Humana.';

  @override
  String get livenessEvidenceThresholdNotMet =>
      'La verificación de detección de vida no alcanzó el umbral requerido. Inténtelo de nuevo.';

  @override
  String get livenessCredentialSessionMissing =>
      'Su credencial de detección de vida no está disponible en esta sesión de la aplicación. Genere una nueva credencial e inténtelo de nuevo.';

  @override
  String get issuedTo => 'Emitido a';

  @override
  String get types => 'Tipos';

  @override
  String get issuer => 'Emisor';

  @override
  String get issuedOn => 'Emitido el';

  @override
  String get human => 'Humano';

  @override
  String get proofFlowThisContact => 'este contacto';

  @override
  String get proofFlowContact => 'Contacto';

  @override
  String proofFlowCheckIfHuman(String contactName) {
    return 'Comprueba si $contactName es humano usando una Prueba de Conocimiento Cero (ZKP) derivada de una Credencial de Detección de Vida.';
  }

  @override
  String get proofFlowRequestProof => 'Solicitar prueba';

  @override
  String proofFlowVerifyingProof(String contactName) {
    return 'Verificando prueba de $contactName...';
  }

  @override
  String proofFlowVerificationFailed(String contactName) {
    return 'Verificación fallida para $contactName';
  }

  @override
  String get zkpNoticePaused =>
      'Has pausado una solicitud de prueba de conocimiento cero humana.';

  @override
  String zkpNoticeDeclined(String contactName) {
    return '$contactName ha rechazado la solicitud de prueba de conocimiento cero humana. Toca el icono \"+\" para reiniciarla.';
  }

  @override
  String get zkpNoticeShared =>
      'Has compartido una Prueba de Conocimiento Cero que confirma que eres humano.\n*No se compartieron datos personales.';

  @override
  String zkpNoticeReceived(String contactName) {
    return '$contactName ha compartido una Prueba de Conocimiento Cero que confirma que es humano.';
  }

  @override
  String zkpNoticeRequest(String contactName) {
    return '$contactName ha solicitado una Prueba de Conocimiento Cero para confirmar que eres humano.\nPuedes generar la prueba usando una Credencial de Detección de Vida existente o completar una verificación rápida de detección de vida.';
  }

  @override
  String get zkpNoticeRequestInitiated =>
      'Has iniciado una solicitud de prueba de conocimiento cero humana.';

  @override
  String get zkpProofAlreadyShared => 'Prueba ZKP ya compartida';

  @override
  String get removeMemberConfirm => 'Eliminar';

  @override
  String get removeMemberNotSupported =>
      'Eliminar miembros aún no está soportado.';

  @override
  String get removeMemberSuccess => 'Miembro eliminado del grupo.';

  @override
  String get generalVideo => 'Vídeo';

  @override
  String get generalVoice => 'Voz';

  @override
  String get generalDocument => 'Documento';

  @override
  String get documentTapToDownload => 'Toca para descargar';

  @override
  String get videoLoadingError => 'No se puede reproducir el vídeo';

  @override
  String get mediaTapToRetry => 'Toca para reintentar';

  @override
  String get mediaDownloadFailedTapToRetry =>
      'Descarga fallida. Toca para reintentar';

  @override
  String attachmentTooLarge(int maxMb) {
    return 'El archivo adjunto es demasiado grande. Tamaño máximo: $maxMb MB.';
  }

  @override
  String get unsupportedFileType => 'Tipo de archivo no compatible.';

  @override
  String get voiceMessagePermissionDenied =>
      'Se requiere permiso de micrófono para grabar mensajes de voz.';

  @override
  String get voiceMessageRecordingFailed =>
      'No se puede iniciar la grabación de voz.';

  @override
  String get voiceMessageSendFailed => 'No se puede enviar el mensaje de voz.';

  @override
  String get generalEmail => 'Correo electrónico';

  @override
  String vrcResponderIntro(Object name) {
    return '$name ha seleccionado la siguiente persona para verificar la relación:';
  }

  @override
  String get videoCallTitle => 'Llamar';

  @override
  String get videoCallJoiningCall => 'Uniéndose a la llamada...';

  @override
  String get videoCallWaitingForParticipants => 'Esperando participantes...';

  @override
  String videoCallShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar $count más',
      one: 'Mostrar 1 más',
    );
    return '$_temp0';
  }

  @override
  String get videoCallShowLess => 'Mostrar menos';

  @override
  String videoCallError(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'channelNotFound': 'No se encontró el canal de la llamada',
      'tokenFetchFailed':
          'No se pudieron obtener las credenciales de la llamada',
      'connectionFailed':
          'No se pudo conectar a la llamada. Revisa el acceso a la sala o inténtalo de nuevo.',
      'groupCallPermissionDenied':
          'No tienes permiso para unirte a esta llamada grupal. Revisa el acceso a la sala o pide ayuda a un administrador del grupo.',
      'callInviteFailed':
          'No se pudo notificar a los otros participantes sobre la llamada',
      'networkError': 'Error de red',
      'unexpected': 'Error inesperado en la llamada',
      'other': 'Error desconocido',
    });
    return '$_temp0';
  }

  @override
  String get videoCallMicToggleFailed =>
      'No se pudo cambiar el micrófono. Por favor, inténtelo de nuevo.';

  @override
  String get videoCallCameraToggleFailed =>
      'No se pudo cambiar la cámara. Por favor, inténtelo de nuevo.';

  @override
  String get videoCallSpeakerToggleFailed =>
      'No se pudo cambiar el altavoz. Por favor, inténtelo de nuevo.';

  @override
  String get videoCallMemberNamesFailed =>
      'No se pudieron cargar los nombres de los participantes.';

  @override
  String get videoCallHangUpFailed =>
      'No se pudo colgar. Por favor, inténtalo de nuevo.';

  @override
  String videoCallParticipantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String get videoCallMute => 'Silenciar';

  @override
  String get videoCallUnmute => 'Activar audio';

  @override
  String get videoCallEnd => 'Terminar';

  @override
  String get videoCallMicPermissionDenied =>
      'Permiso de micrófono denegado. Actívalo en Configuración.';

  @override
  String get videoCallCameraPermissionDenied =>
      'Permiso de cámara denegado. Actívalo en Configuración.';

  @override
  String get videoCallWaitingForEncryption => 'Configurando el cifrado...';

  @override
  String get videoCallYou => 'Tú';

  @override
  String get videoCallRinging => 'Llamando';

  @override
  String get videoCallCalling => 'Llamando...';

  @override
  String get videoCallCancelCall => 'Cancelar';

  @override
  String get videoCallNoAnswer => 'Sin respuesta';

  @override
  String get videoCallCallDeclined => 'Llamada rechazada';

  @override
  String get videoCallCallFailed => 'La llamada falló';

  @override
  String get videoCallCallEnded => 'Llamada finalizada';

  @override
  String get videoCallCancel => 'Cancelar';

  @override
  String get videoCallAgain => 'Volver a llamar';

  @override
  String get videoCallGroupCallJoin => 'Unirse';

  @override
  String get videoCallGroupCallActive => 'Llamada grupal en curso';

  @override
  String videoCallOngoingCall(int count) {
    return 'Llamada en curso ($count)';
  }

  @override
  String get videoCallSwitch => 'Cambiar';

  @override
  String get videoCallSwitchToVideoTitle => '¿Cambiar a videollamada?';

  @override
  String incomingCallBannerIsCalling(String callerName) {
    return '$callerName está llamando';
  }

  @override
  String get incomingCallBannerAccept => 'Aceptar';

  @override
  String get incomingCallBannerDecline => 'Rechazar';

  @override
  String get incomingCallBannerUnknownCaller => 'Llamante desconocido';

  @override
  String get incomingCallBannerAudioCall => 'Audio de MeetingPlace';

  @override
  String get incomingCallBannerVideoCall => 'Video de MeetingPlace';

  @override
  String get callChatItemAudioCall => 'Llamada de audio';

  @override
  String get callChatItemVideoCall => 'Videollamada';

  @override
  String get callChatItemCalling => 'Llamando...';

  @override
  String get callChatItemRinging => 'Sonando';

  @override
  String get callChatItemIncoming => 'Llamada entrante';

  @override
  String get callChatItemTapToReturn => 'Toca para volver';

  @override
  String get callChatItemMissed => 'Perdida';

  @override
  String get callChatItemNotAnswered => 'Sin respuesta';

  @override
  String get callChatItemDeclined => 'Rechazada';

  @override
  String callChatItemGroupOngoingVideo(int count) {
    return 'Videollamada en curso ($count)';
  }

  @override
  String callChatItemGroupOngoingAudio(int count) {
    return 'Llamada de audio en curso ($count)';
  }

  @override
  String get callChatItemYouLeft => 'Saliste';

  @override
  String get callLogScreenTitle => 'Registro de llamadas';

  @override
  String get callLogScreenSubtitle =>
      'Tus llamadas de audio y video anteriores.';

  @override
  String get callLogEmpty => 'Aún no hay llamadas.';

  @override
  String callLogParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String callLogParticipantsNamesAndOthers(String names, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount más',
      one: '1 más',
    );
    return '$names y $_temp0';
  }

  @override
  String get callLogInProgress => 'En curso';

  @override
  String get callLogError => 'No se pudo cargar el registro de llamadas.';

  @override
  String callDurationHourFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h',
      one: '1 h',
    );
    return '$_temp0';
  }

  @override
  String callDurationMinuteFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count m',
      one: '1 m',
    );
    return '$_temp0';
  }

  @override
  String callDurationSecondFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count s',
      one: '1 s',
    );
    return '$_temp0';
  }

  @override
  String get groupCallWaitingForOthers => 'Esperando a otros...';

  @override
  String get groupCallParticipant => 'participante';

  @override
  String get groupCallParticipants => 'participantes';

  @override
  String get groupCallEndCall => 'Finalizar llamada';

  @override
  String get groupCallNoParticipants => 'Sin participantes';

  @override
  String get groupCallMute => 'Silenciar';

  @override
  String get groupCallLeave => 'Salir';

  @override
  String get videoCallMuted => 'Silenciado';

  @override
  String videoCallPeerMuted(String peerName) {
    return '$peerName está silenciado';
  }

  @override
  String callParticipantsConnectedCount(int count) {
    return '$count conectados';
  }

  @override
  String get callParticipantsConnectedSection => 'Conectados';

  @override
  String get callParticipantsNotConnectedSection => 'No conectados';

  @override
  String callParticipantCallAction(String name) {
    return 'Llamar a $name';
  }

  @override
  String callParticipantRingingAction(String name) {
    return 'Llamando a $name';
  }

  @override
  String get linkedVtaTitle => 'Linked VTA';

  @override
  String get linkedVtaHelperText =>
      'Link your Verifiable Trust Agent (VTA) so Meeting Place can act for you with it.';

  @override
  String get linkedVtaDidLabel => 'VTA DID';

  @override
  String get linkedVtaLinkAction => 'Link';

  @override
  String get linkedVtaInvalidDid =>
      'Enter the DID of your VTA, for example did:webvh:…';

  @override
  String get linkedVtaUnreachable => 'Your VTA couldn\'t be reached.';

  @override
  String get linkedVtaAlreadyLinked =>
      'A VTA is already linked. Remove it before linking another one.';

  @override
  String get linkedVtaBadAnswer => 'Your VTA\'s answer couldn\'t be verified.';

  @override
  String get linkedVtaScreenTitle => 'Connect your VTA';

  @override
  String get linkedVtaPendingTitle => 'Add this phone to your VTA';

  @override
  String get linkedVtaManagerDidLabel => 'This phone\'s DID';

  @override
  String get linkedVtaCopyDid => 'Copy DID';

  @override
  String get linkedVtaGrantInstruction =>
      'Ask your VTA admin to grant this DID by running:';

  @override
  String get linkedVtaGrantWarning =>
      'This makes Meeting Place an admin of your VTA, able to create and use your identities (persona-holder). Only grant it to a phone you own.';

  @override
  String get linkedVtaCopyCommand => 'Copy command';

  @override
  String get linkedVtaWaiting => 'Waiting for your admin…';

  @override
  String get linkedVtaWaitingForPersonaHolder =>
      'Admin role granted. Waiting for the persona-holder capability…';

  @override
  String get linkedVtaStillTrying =>
      'Your VTA couldn\'t be reached. Still trying…';

  @override
  String get linkedVtaStoppedWaiting => 'Stopped checking after 10 minutes.';

  @override
  String get linkedVtaCheckAgain => 'Check again';

  @override
  String get linkedVtaNoDidcomm =>
      'Your VTA doesn\'t offer DIDComm, which Meeting Place uses to talk to it. Ask its admin to enable DIDComm with a mediator.';

  @override
  String get linkedVtaScanAction => 'Scan code from your VTA host';

  @override
  String get linkedVtaManualHint =>
      'Or paste the enrolment link from your VTA host, or your VTA\'s DID:';

  @override
  String get linkedVtaFieldLabel => 'Enrolment link or VTA DID';

  @override
  String get linkedVtaEnrolmentTitle => 'Compare the codes';

  @override
  String get linkedVtaEnrolmentCodeLabel => 'Code on this phone';

  @override
  String get linkedVtaEnrolmentInstruction =>
      'Your VTA host shows a code too. Your VTA admin must check that it is exactly this code before granting access.';

  @override
  String get linkedVtaEnrolmentWarning =>
      'If the codes differ, someone else\'s key was submitted: don\'t grant access, and cancel here.';

  @override
  String get linkedVtaWaitingForHost =>
      'Waiting for your admin to grant access on your VTA host…';

  @override
  String get linkedVtaOfferMalformed =>
      'This isn\'t a valid enrolment code. Scan the code your VTA host shows again.';

  @override
  String get linkedVtaOfferUnsupported =>
      'This enrolment code is from a newer version of the VTA host. Update Meeting Place, or link your VTA by its DID.';

  @override
  String get linkedVtaOfferInsecure =>
      'This enrolment code points to a host that isn\'t secured with HTTPS, so it can\'t be used.';

  @override
  String get linkedVtaOfferExpired =>
      'This enrolment code has expired. Ask your VTA host for a new one.';

  @override
  String get linkedVtaOfferUsed =>
      'This enrolment code was already used. Ask your VTA host for a new one.';

  @override
  String get linkedVtaEnrolmentRejected =>
      'Your VTA host didn\'t accept this phone. Ask it for a new enrolment code.';

  @override
  String get linkedVtaCodeMismatch =>
      'Your VTA host answered with a different code, so it didn\'t receive this phone\'s key. Ask it for a new enrolment code.';

  @override
  String get linkedVtaHostUnreachable => 'Your VTA host couldn\'t be reached.';

  @override
  String get linkedVtaEnrolmentRefused =>
      'Your VTA admin refused access for this phone.';

  @override
  String get linkedVtaEnrolmentExpired =>
      'The enrolment code expired before your VTA admin granted access. Ask your VTA host for a new one.';

  @override
  String get identityPersonaTitle => 'Persona on your VTA';

  @override
  String get identityPersonaHint =>
      'Your VTA holds this identity\'s keys. Contacts never see this DID.';

  @override
  String get identityPersonaCopyDid => 'Copy persona DID';

  @override
  String get identityVtaSaveFailed =>
      'Your VTA couldn\'t save this identity. Check it\'s reachable and try again.';

  @override
  String get identityVtaDeleteFailed =>
      'Your VTA couldn\'t delete this identity. Check it\'s reachable and try again.';

  @override
  String get identityDeleteConfirmTitle => 'Delete this identity?';

  @override
  String get identityDeleteConfirmMessage =>
      'Its persona is deleted from your VTA, and its DID can never be used again.';

  @override
  String get linkedVtaUnlinkAction => 'Remove';

  @override
  String get vtcSignInMenuTitle => 'Sign in to community';

  @override
  String get vtcSignInMenuSubtitle =>
      'Approve a sign-in code from your community\'s website';

  @override
  String get vtcSignInUseMembership => 'Use this membership';

  @override
  String get vtcSignInEnterNumber =>
      'Enter the two-digit number shown in your browser.';

  @override
  String get vtcSignInNumberLabel => 'Number';

  @override
  String get vtcSignInContinue => 'Continue';

  @override
  String get vtcSignInReviewHeading => 'Approve this sign-in?';

  @override
  String get vtcSignInSameNetwork => 'On the same network as this phone';

  @override
  String get vtcSignInOtherNetwork => 'On a different network than this phone';

  @override
  String get vtcSignInReportedNote =>
      'Reported by the community. Only that one browser session will be signed in.';

  @override
  String get vtcSignInApprove => 'Approve';

  @override
  String get vtcSignInDecline => 'Decline';

  @override
  String get vtcSignInApproved => 'You\'re signed in on that browser.';

  @override
  String get vtcSignInDeclined => 'The sign-in was declined.';

  @override
  String get vtcSignInVtaMissing =>
      'Link your VTA in Settings before signing in to a community.';

  @override
  String get vtcSignInDone => 'Done';

  @override
  String vtcSignInFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'expired': 'This code has expired. Get a new one.',
      'invalid': 'This code can\'t be used.',
      'update': 'This code needs a newer version of the app.',
      'unreachable': 'This community can\'t be reached from your phone.',
      'notAMember':
          'This sign-in code is from a community you haven\'t joined.',
      'noSignIn': 'This community doesn\'t offer sign-in from the app.',
      'alreadyClaimed':
          'Another device already scanned this code. Refresh the sign-in page and scan the new code.',
      'notFound':
          'This sign-in has ended. Refresh the sign-in page and scan the new code.',
      'refused':
          'The community didn\'t accept this sign-in. Refresh the sign-in page and try again.',
      'notAnAdmin': 'This identity isn\'t an administrator of this community.',
      'badAnswer':
          'The community\'s answer couldn\'t be checked, so nothing was signed in.',
      'badNumber': 'Enter the two digits shown on the sign-in page.',
      'wrongNumber':
          'That isn\'t the number on the sign-in page. Refresh the page and scan the new code.',
      'noVaultEntry':
          'Your VTA isn\'t set up to sign in to this community yet.',
      'notEnrolledDevice':
          'This phone isn\'t registered with your VTA, so it can\'t sign in.',
      'noUvKey':
          'This phone isn\'t set up to approve sign-ins with your VTA yet.',
      'uvRequired': 'Your VTA needs your approval on this phone to sign in.',
      'uvCancelled': 'The sign-in wasn\'t approved.',
      'uvKeyLost':
          'Your Face ID or fingerprints changed, so approving sign-ins must be set up again. Unlink and link your VTA in Settings.',
      'uvUnavailable': 'This phone couldn\'t approve the sign-in.',
      'grantReplayed':
          'This approval was already used. Refresh the sign-in page and scan the new code.',
      'assertionMethodMissing':
          'Your identity in this community can\'t approve sign-ins yet.',
      'agentRefused': 'Your VTA refused this sign-in.',
      'agentNeedsUpdate':
          'Your VTA needs an update before it can sign you in to websites.',
      'agentUnreachable': 'Your VTA couldn\'t be reached.',
      'other':
          'The community didn\'t accept this sign-in. Refresh the sign-in page and try again.',
    });
    return '$_temp0';
  }

  @override
  String vtcSignInLinkProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'update': 'This code needs a newer version of the app.',
      'expired': 'This code has expired. Get a new one.',
      'unreachable': 'This service can\'t be reached from your phone.',
      'other': 'This code can\'t be used.',
    });
    return '$_temp0';
  }

  @override
  String vtcSignInAudience(String audience) {
    String _temp0 = intl.Intl.selectLogic(audience, {
      'admin': 'Operator console',
      'other': 'Member portal',
    });
    return '$_temp0';
  }

  @override
  String vtcSignInTitle(String community) {
    return 'Sign in to $community';
  }

  @override
  String vtcSignInWebsite(String origin) {
    return 'Website: $origin';
  }

  @override
  String vtcSignInFoundMembership(String community) {
    return 'Your membership of $community was found on your VTA. Sign in as this identity?';
  }

  @override
  String vtcSignInTimeLeft(int seconds) {
    return '$seconds s left';
  }

  @override
  String get vtcSignInAs => 'Signing in as';

  @override
  String vtcSignInBrowser(String browser, String os) {
    return 'Browser: $browser on $os';
  }

  @override
  String vtcSignInLocation(String location) {
    return 'Location: $location';
  }

  @override
  String get linkedVtaDidNotResolved =>
      'Your VTA\'s DID couldn\'t be resolved from this phone. Check the DID, and that its host can be reached from this phone over HTTPS.';

  @override
  String get vtcJoinMenuTitle => 'Join a community';

  @override
  String get vtcJoinIntroTitle => 'Become a member of a community';

  @override
  String get vtcJoinIntro =>
      'Scan the community\'s QR code, paste its DID, or enter its join phrase. You see what it asks before anything is sent.';

  @override
  String get vtcJoinDidHint => 'Community DID or join phrase';

  @override
  String get vtcJoinScanAction => 'Scan QR code';

  @override
  String get vtcJoinPasteAction => 'Paste';

  @override
  String get vtcJoinContinueAction => 'Continue';

  @override
  String get vtcJoinMenuSubtitle =>
      'Scan a community\'s code and apply with your VTA';

  @override
  String get vtcJoinChooseIdentity => 'Join with which identity?';

  @override
  String vtcJoinShareDetails(String name) {
    return 'Share these details with $name?';
  }

  @override
  String get vtcJoinShareAction => 'Share and apply';

  @override
  String get vtcJoinCredentialMissing => 'Credential missing';

  @override
  String get mockCredentialsTitle => 'Mock credentials';

  @override
  String get mockCredentialsSubtitle => 'Test credentials for your identities';

  @override
  String get mockCredentialsNote =>
      'This phone signs these as a test issuer. Import one for an identity, then join a community whose way in asks for it and accepts any issuer.';

  @override
  String get mockCredentialsImport => 'Import';

  @override
  String get mockCredentialsChooseIdentity => 'Import for which identity?';

  @override
  String mockCredentialsHeldBy(String name) {
    return 'Held by $name';
  }

  @override
  String mockCredentialsImported(String name) {
    return 'Imported for $name';
  }

  @override
  String get mockCredentialsNotKept =>
      'Your VTA took the credential but doesn\'t keep it as valid.';

  @override
  String get mockCredentialsImportFailed =>
      'The credential couldn\'t be imported: your VTA refused it or can\'t be reached.';

  @override
  String mockCredentialsRefused(String reason) {
    return 'Your VTA refused the credential: $reason';
  }

  @override
  String get mockCredentialsNoIdentities =>
      'Create an identity on your VTA to import a credential for it.';

  @override
  String get mockCredentialsVtaMissing =>
      'Link your VTA in Settings to import test credentials.';

  @override
  String get mockCredentialsUnreachable => 'Your VTA can\'t be reached.';

  @override
  String vtcJoinWayWithCredential(String type) {
    return 'With your $type';
  }

  @override
  String vtcJoinShareCredential(String name) {
    return 'Present this credential to $name?';
  }

  @override
  String get vtcJoinCredentialIssuer => 'Issued by';

  @override
  String get vtcJoinCredentialClaimsHeading => 'What presenting it shows';

  @override
  String get vtcJoinCredentialNote =>
      'The whole credential goes with your application, which this identity signs.';

  @override
  String get vtcJoinNewIdentity => 'A new identity';

  @override
  String get vtcJoinNewIdentityHost => 'Created on your VTA for this community';

  @override
  String get vtcJoinExistingIdentity => 'Existing identity';

  @override
  String get vtcJoinUseIdentity => 'Join with this identity';

  @override
  String vtcJoinIdentityPosition(int position, int total) {
    return '$position of $total · swipe to see the others';
  }

  @override
  String get vtcJoinNewIdentityNote =>
      'Recommended: your VTA creates it for this community, so other communities can\'t link you through it.';

  @override
  String get vtcJoinWaysHeading => 'Ways in';

  @override
  String get vtcJoinManifestHeading => 'Manifest';

  @override
  String get vtcJoinShowManifest => 'Show the community\'s manifest';

  @override
  String get vtcJoinWayAutomatic => 'You become a member when you apply';

  @override
  String get vtcJoinWayReviewed => 'The administrators review your application';

  @override
  String vtcJoinWayUnsupported(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'invitation': 'Not supported yet: needs an invitation',
      'credentials': 'Not supported yet: needs credentials',
      'vetting': 'Not supported yet: needs an in-person check',
      'other': 'Not supported yet',
    });
    return '$_temp0';
  }

  @override
  String vtcJoinNoSupportedWay(String name) {
    return 'Meeting Place doesn\'t support any way into $name yet, so you can\'t apply from here.';
  }

  @override
  String get vtcJoinDetailsHeading => 'Profile details the community asks for';

  @override
  String get vtcJoinDetailsNote =>
      'You see the values from your VTA and approve sharing them before anything is sent.';

  @override
  String get vtcJoinDirectoryListed =>
      'This community lists new members in its member directory.';

  @override
  String get vtcJoinDirectoryHidden =>
      'This community doesn\'t list new members in its member directory.';

  @override
  String get vtcJoinListMe => 'List me in the member directory';

  @override
  String get vtcJoinListMeNote =>
      'If this is off, you may be listed for a moment when you join, until Meeting Place takes your card out of the directory.';

  @override
  String get vtcCommunityRole => 'Your role';

  @override
  String get vtcCommunitySettings => 'Community settings';

  @override
  String vtcCommunityRoleName(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'Administrator',
      'moderator': 'Moderator',
      'issuer': 'Issuer',
      'member': 'Member',
      'vetter': 'Vetter',
      'other': '$role',
    });
    return '$_temp0';
  }

  @override
  String get vtcJoinProfileHeading => 'About the community';

  @override
  String get vtcJoinWebsite => 'Website';

  @override
  String get vtcJoinContact => 'Contact';

  @override
  String vtcJoinAudience(String audience) {
    String _temp0 = intl.Intl.selectLogic(audience, {
      'admins': 'the administrators',
      'groups': 'your groups',
      'connections': 'your connections',
      'members': 'all members',
      'public': 'anyone',
      'other': 'some people',
    });
    return '$_temp0';
  }

  @override
  String get vtcJoinFieldSetByAdmins => 'Set by admins';

  @override
  String get vtcJoinExternalCards =>
      'You may publish your card beyond the community, if you choose to.';

  @override
  String get vtcJoinUnnamedCommunity => 'A community';

  @override
  String get vtcJoinThisCommunity => 'this community';

  @override
  String get vtcJoinWantsYou => 'wants you to join';

  @override
  String get vtcJoinWithVtaIdentity => 'With an identity from your VTA';

  @override
  String vtcJoinConsentHeading(String name) {
    return 'If you join, $name can:';
  }

  @override
  String vtcJoinReceivesDetail(String type) {
    return 'Receive your $type';
  }

  @override
  String get vtcClaimTypeNameDisplay => 'display name';

  @override
  String get vtcClaimTypeNameGiven => 'first name';

  @override
  String get vtcClaimTypeNameFamily => 'last name';

  @override
  String get vtcClaimTypeNameLegal => 'legal name';

  @override
  String get vtcClaimTypeEmailPersonal => 'personal email';

  @override
  String get vtcClaimTypeEmailWork => 'work email';

  @override
  String get vtcClaimTypePhoneMobile => 'mobile number';

  @override
  String get vtcClaimTypePhoneWork => 'work phone number';

  @override
  String get vtcClaimTypeAddressCountry => 'country';

  @override
  String get vtcClaimTypePersonBirthDate => 'date of birth';

  @override
  String get vtcClaimTypeSkillLanguage => 'languages';

  @override
  String get vtcClaimTypeAccountHandle => 'account handle';

  @override
  String get vtcJoinDetailRequiredNote => 'Required to apply';

  @override
  String get vtcJoinDetailOptionalNote => 'Optional';

  @override
  String vtcJoinShowsTo(String fields, String audience) {
    return 'Show your $fields to $audience';
  }

  @override
  String get vtcJoinMembershipDidField => 'membership ID';

  @override
  String vtcJoinListAnd(String rest, String last) {
    return '$rest and $last';
  }

  @override
  String get vtcJoinKeepsNotes => 'Keep notes about you';

  @override
  String get vtcJoinAdminNotesDetail =>
      'No other member sees them, and you can ask for yours.';

  @override
  String vtcJoinFieldSeenBy(String audience) {
    return 'Seen by: $audience';
  }

  @override
  String vtcJoinFieldWidenTo(String audience) {
    return 'You can widen to: $audience';
  }

  @override
  String get vtcJoinAction => 'Join';

  @override
  String vtcJoinCardRoute(String community, String identity) {
    return '$community issued your membership card to $identity, which passed it on to your VTA';
  }

  @override
  String vtcJoinJoined(String name) {
    return 'You\'re a member of $name.';
  }

  @override
  String get vtcJoinLeaveAction => 'Leave community';

  @override
  String vtcJoinLeaveTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get vtcJoinLeaveMessage =>
      'The community ends your membership, and your VTA archives your membership card. To come back, you apply again.';

  @override
  String vtcJoinLeft(String name) {
    return 'You left $name.';
  }

  @override
  String vtcJoinPending(String name) {
    return 'Your application to $name is waiting for the community\'s decision.';
  }

  @override
  String get vtcJoinCheckAgain => 'Check again';

  @override
  String vtcIdentityCheckHeading(String name) {
    return '$name checked your identity';
  }

  @override
  String get vtcIdentityCheckHow => 'How';

  @override
  String vtcIdentityCheckMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'inPerson': 'In person',
      'video': 'By video call',
      'priorAcquaintance': 'They already knew you',
      'other': '$method',
    });
    return '$_temp0';
  }

  @override
  String get vtcIdentityCheckDocuments => 'Documents seen';

  @override
  String vtcIdentityCheckDocument(String document) {
    String _temp0 = intl.Intl.selectLogic(document, {
      'passport': 'Passport',
      'nationalId': 'National ID card',
      'other': '$document',
    });
    return '$_temp0';
  }

  @override
  String get vtcIdentityCheckConfirmed => 'Confirmed';

  @override
  String get vtcIdentityCheckLiveness => 'That you were there';

  @override
  String get vtcIdentityCheckCheckedOn => 'Checked on';

  @override
  String get vtcIdentityCheckValidUntil => 'Valid until';

  @override
  String get vtcIdentityCheckShow => 'Show the signed statement';

  @override
  String get vtcMembershipCardTitle => 'Membership card';

  @override
  String get vtcMembershipCardShow => 'Show the card';

  @override
  String get vtcMembershipCardPersonhood => 'Personhood';

  @override
  String get vtcMembershipCardMember => 'Member';

  @override
  String get vtcMembershipCardIssuedBy => 'Issued by';

  @override
  String get vtcMembershipCardValidFrom => 'Valid from';

  @override
  String get vtcMembershipCardValidUntil => 'Valid until';

  @override
  String get vtcMembershipCardKept => 'Kept on your VTA';

  @override
  String get vtcMembershipCardOnItsWay =>
      'Your membership card is on its way to your VTA';

  @override
  String get vtcMembershipCardLoading => 'Getting your membership card…';

  @override
  String get vtcJoinWithdrawAction => 'Withdraw application';

  @override
  String vtcJoinWithdrawTitle(String name) {
    return 'Withdraw your application to $name?';
  }

  @override
  String get vtcJoinWithdrawMessage =>
      'The community\'s administrators won\'t decide on it any more. You can apply again afterwards.';

  @override
  String vtcJoinWithdrawn(String name) {
    return 'You withdrew your application to $name.';
  }

  @override
  String get vtcJoinApplyAgain => 'Apply again';

  @override
  String get vtcJoinTrailHeading => 'Your application';

  @override
  String get vtcJoinTrailPresentation => 'Your credential, presented';

  @override
  String vtcJoinTrailPresentationSummary(String types) {
    return '$types · inside your signed application';
  }

  @override
  String get vtcJoinTrailHolder => 'Holder';

  @override
  String get vtcJoinTrailCredential => 'Credential';

  @override
  String get vtcJoinTrailIssuer => 'Issued by';

  @override
  String get vtcJoinTrailValidUntil => 'Valid until';

  @override
  String get vtcJoinTrailPresentationDocument => 'Your presentation';

  @override
  String get vtcTrailDoneBy => 'Done by';

  @override
  String get vtcTrailTasks => 'Trust Tasks';

  @override
  String get vtcJoinTrailVta => 'Signed by your VTA';

  @override
  String vtcJoinTrailVtaIdentity(String name) {
    return 'As your identity in $name';
  }

  @override
  String vtcJoinTrailVtaSummary(String name, String cryptosuite, String time) {
    return 'As your identity in $name · $cryptosuite · $time';
  }

  @override
  String get vtcJoinTrailCommunitySummary =>
      'Passed to its administrators · its signed answer verified';

  @override
  String vtcJoinTrailCommunity(String name) {
    return 'Received by $name';
  }

  @override
  String get vtcJoinTrailNoReceipt =>
      'Sent earlier; this phone keeps no receipt for it';

  @override
  String get vtcJoinTrailReview => 'Waiting for the administrators';

  @override
  String get vtcJoinTrailDeferred => 'Put off by the administrators for now';

  @override
  String vtcJoinTrailLastChecked(String time) {
    return 'Last checked at $time';
  }

  @override
  String vtcJoinTrailAutoCheck(int seconds) {
    return 'Checked again every $seconds seconds while this screen is open';
  }

  @override
  String get vtcJoinTrailCard => 'Membership card';

  @override
  String get vtcJoinTrailCardSummary =>
      'Issued once you\'re admitted, and kept on your VTA';

  @override
  String get vtcJoinTrailWithdrawn => 'Withdrawn, signed by your VTA';

  @override
  String vtcJoinTrailWithdrawnSummary(String name) {
    return '$name confirmed it · its signed answer verified';
  }

  @override
  String vtcJoinTrailWithdrawnNotHeld(String name) {
    return '$name no longer held it open';
  }

  @override
  String get vtcJoinTrailWithdrawnDocument => 'Your withdrawal and its receipt';

  @override
  String get vtcJoinTrailIdentity => 'Identity';

  @override
  String get vtcJoinTrailTask => 'Trust Task';

  @override
  String get vtcJoinTrailKey => 'Signing key';

  @override
  String get vtcJoinTrailCryptosuite => 'Cryptosuite';

  @override
  String get vtcJoinTrailSignedAt => 'Signed at';

  @override
  String get vtcJoinTrailRequestId => 'Request id at the community';

  @override
  String get vtcJoinTrailCheckTask => 'Last check';

  @override
  String get vtcJoinTrailCheckSignedAt => 'Last check signed by your VTA at';

  @override
  String get vtcJoinTrailCheckAnsweredAt =>
      'Last check answered and verified at';

  @override
  String get vtcJoinTrailProofPurpose => 'Proof purpose';

  @override
  String get vtcJoinTrailCheckAnswerKey => 'Key that signed the last answer';

  @override
  String get vtcJoinJsonCopy => 'Copy JSON';

  @override
  String get vtcJoinTrailShowDocument => 'Show the signed document';

  @override
  String get vtcJoinTrailSubmitDocument => 'Your signed application';

  @override
  String get vtcJoinTrailAnswerDocument => 'The community\'s signed answer';

  @override
  String get vtcJoinTrailCheckDocument => 'The community\'s last signed answer';

  @override
  String get vtcJoinTrailAnsweredBy => 'Answered by';

  @override
  String get vtcJoinTrailAnsweredAt => 'Answered at';

  @override
  String get vtcDeliveryHeading => 'How your card arrived';

  @override
  String get vtcDeliveryKeysLent => 'Keys lent by your VTA';

  @override
  String get vtcDeliveryKeysLentSummary =>
      'Held in memory only, while this screen collects the card';

  @override
  String get vtcDeliveryKeysFailed =>
      'Your VTA didn\'t lend the keys. Trying again';

  @override
  String get vtcDeliveryKeyAgreementKey => 'Key agreement key';

  @override
  String get vtcDeliverySignedIn => 'Signed in to your identity\'s inbox';

  @override
  String vtcDeliveryWaitingMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages waiting',
      one: '1 message waiting',
      zero: 'No messages waiting',
    );
    return '$_temp0';
  }

  @override
  String get vtcDeliverySignedInFailed =>
      'Couldn\'t reach the inbox. Trying again';

  @override
  String get vtcDeliveryInboxNoTask =>
      'None: the inbox is signed in to and read over DIDComm';

  @override
  String get vtcDeliveryMediator => 'Mediator';

  @override
  String vtcDeliveryPickedUp(String name) {
    return 'Card picked up from $name';
  }

  @override
  String vtcDeliveryPickedUpSummary(String name) {
    return 'Signed by $name · proof verified';
  }

  @override
  String vtcDeliveryWaiting(String name) {
    return 'Waiting for $name to deliver it';
  }

  @override
  String get vtcDeliverySentBy => 'Sent by';

  @override
  String get vtcDeliveryIssueDocument => 'The community\'s signed delivery';

  @override
  String get vtcDeliveryKept => 'Kept on your VTA';

  @override
  String get vtcDeliveryKeptSummary => 'Proof checked by your VTA';

  @override
  String get vtcDeliveryKeptInvalid =>
      'Kept, but your VTA finds it revoked or expired';

  @override
  String get vtcDeliveryKeptFailed => 'Your VTA didn\'t keep it. Trying again';

  @override
  String vtcDeliveryConfirmed(String name) {
    return 'Membership confirmed with $name';
  }

  @override
  String get vtcDeliveryConfirmedSummary =>
      'Your identity signed the card back to the community';

  @override
  String get vtcDeliveryConfirmedFailed => 'Not confirmed yet. Trying again';

  @override
  String get vtcDeliveryNext => 'Still to come';

  @override
  String vtcJoinDenied(String name) {
    return '$name didn\'t accept your application.';
  }

  @override
  String vtcJoinLastDenied(String reason) {
    return 'Your last application was turned down. The community\'s reason: $reason';
  }

  @override
  String vtcJoinDeniedWithReason(String name, String reason) {
    return '$name didn\'t accept your application. Its reason: $reason';
  }

  @override
  String get vtcJoinNeedsMore =>
      'The community needs more than Meeting Place can send, such as credentials.';

  @override
  String vtcJoinFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'invalidCode': 'This isn\'t a community\'s code.',
      'phraseNotFound': 'No community goes by this phrase in Meeting Place.',
      'phraseExpired':
          'This join phrase has expired. Ask the community for its current phrase.',
      'profileMissing':
          'Your VTA has no profile for this identity, so it can\'t share the details the community asks for. Set up your profile on your VTA, then try again.',
      'detailsMissing':
          'Your VTA doesn\'t hold a detail the community requires, so nothing was sent.',
      'credentialMissing':
          'Your identity holds no credential this way in accepts that your VTA can present, so nothing was sent.',
      'vtaMissing': 'Link your VTA in Settings before joining a community.',
      'unreachable': 'The community can\'t be reached from your phone.',
      'noDidHosting':
          'Your VTA has no DID hosting server, so it can\'t create an identity the community can find.',
      'notAccepting': 'This community isn\'t accepting applications.',
      'badAnswer':
          'The community\'s answer couldn\'t be checked, so nothing was recorded.',
      'lastAdministrator':
          'You\'re this community\'s last administrator. Make another member an administrator before you leave.',
      'other': 'The community or your VTA refused the application.',
    });
    return '$_temp0';
  }

  @override
  String get vtaDetailsTitle => 'VTA details';

  @override
  String get vtaDetailsContextId => 'Context ID';

  @override
  String get vtaDetailsProfileId => 'Profile ID';

  @override
  String get vtaDetailsProfile => 'Profile';

  @override
  String get vtaDetailsCopyProfile => 'Copy profile';

  @override
  String get vtaDetailsProfileFailed =>
      'Couldn\'t read this profile from your VTA.';

  @override
  String vtaDetailsValueShortened(String start, int length) {
    return '$start… ($length characters)';
  }

  @override
  String get vtcJoinPhraseHeading => 'Join phrase';

  @override
  String vtcJoinPhraseIntro(String name) {
    return 'Let people find $name in Meeting Place by a short phrase instead of its DID. They see the community and where it is hosted before they apply.';
  }

  @override
  String get vtcJoinPhrasePublishAction => 'Publish join phrase';

  @override
  String vtcJoinPhraseDialogTitle(String name) {
    return 'Join phrase for $name';
  }

  @override
  String get vtcJoinPhraseHint => 'Phrase';

  @override
  String vtcJoinPhraseOfferDescription(String name) {
    return 'Join $name in Meeting Place';
  }

  @override
  String vtcJoinPhrasePublished(String name, String phrase) {
    return 'People find $name by entering \"$phrase\" or scanning this code in Meeting Place, until you withdraw it.';
  }

  @override
  String get vtcJoinPhraseVisibility =>
      'The phrase shows only the community\'s DID, nothing about you. Anyone can publish a phrase for any community, so people still check the community before they apply.';

  @override
  String get vtcJoinPhraseWithdrawAction => 'Withdraw phrase';

  @override
  String vtcJoinPhraseWithdrawTitle(String phrase) {
    return 'Withdraw \"$phrase\"?';
  }

  @override
  String get vtcJoinPhraseWithdrawMessage =>
      'Meeting Place stops listing the phrase, and anyone can then publish it again.';

  @override
  String vtcJoinPhraseFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'taken': 'That phrase is already taken in Meeting Place. Try another.',
      'other': 'The phrase couldn\'t be published or withdrawn. Try again.',
    });
    return '$_temp0';
  }

  @override
  String get vtcFindableHeading => 'Let members find you';

  @override
  String vtcFindableIntro(String name) {
    return 'Let members of $name find you to vouch for you. They\'ll see the identity you joined with.';
  }

  @override
  String vtcFindableNotAllowed(String name) {
    return '$name doesn\'t let members show this.';
  }

  @override
  String get vtcFindableFailed => 'Couldn\'t change this. Try again.';

  @override
  String get vtcTrustHeading => 'Community trust';

  @override
  String get vtcTrustVouchInCommunity => 'Vouch in a community';

  @override
  String vtcTrustTheyVouched(String name) {
    return '$name vouched for you';
  }

  @override
  String get vtcTrustNoVouch => 'No vouches yet';

  @override
  String get vtcTrustVouch => 'Vouch';

  @override
  String get vtcTrustVouchBack => 'Vouch back';

  @override
  String get vtcTrustWithdraw => 'Withdraw';

  @override
  String get vtcTrustPickCommunity => 'Vouch in which community?';

  @override
  String vtcTrustSearchTitle(String name, String community) {
    return 'Find $name in $community';
  }

  @override
  String get vtcTrustSearchHint => 'Name';

  @override
  String get vtcTrustSearchNone => 'No members match.';

  @override
  String get vtcTrustUnnamed => 'Unnamed member';

  @override
  String vtcTrustNotFindable(String name, String community) {
    return '$name hasn\'t let members of $community find them yet.';
  }

  @override
  String vtcTrustConfirmMatchTitle(String contact) {
    return 'Is this $contact?';
  }

  @override
  String vtcTrustConfirmMatchMessage(
    String contact,
    String community,
    String member,
  ) {
    return 'Your vouches for $contact in $community will name $member.';
  }

  @override
  String get vtcTrustConfirmMatchAction => 'Yes, that\'s them';

  @override
  String vtcTrustConsentTitle(String name, String community) {
    return 'Vouch for $name in $community?';
  }

  @override
  String vtcTrustConsentMessage(String name, String community) {
    return 'This tells members of $community that you and $name know each other. You\'ll each also see what the other shares with their connections.';
  }

  @override
  String vtcTrustWithdrawTitle(String name, String community) {
    return 'Stop vouching for $name in $community?';
  }

  @override
  String get vtcTrustWithdrawMessage => 'Members will no longer see it.';

  @override
  String vtcTrustDoneTitle(String name) {
    return 'You vouched for $name';
  }

  @override
  String get vtcTrustSigned => 'Signed by your VTA';

  @override
  String vtcTrustSignedSummary(String community) {
    return 'As the identity you joined $community with.';
  }

  @override
  String vtcTrustStored(String community) {
    return 'Stored by $community';
  }

  @override
  String get vtcTrustVouchDocument => 'Signed vouch';

  @override
  String vtcTrustFailure(String reason, String community, String name) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'notMember': 'You\'re not a member of $community any more.',
      'contactNotMember': '$name isn\'t a member of $community any more.',
      'notFindable': '$name hasn\'t let members of $community find them yet.',
      'searchTooShort': 'Enter at least three letters.',
      'nameRefused': '$community doesn\'t accept this name.',
      'proofRejected': '$community didn\'t accept your VTA\'s signature.',
      'notAllowed': '$community doesn\'t allow this.',
      'tryLater': '$community is busy. Try again in a moment.',
      'vtaUnavailable':
          'Your VTA couldn\'t sign this. Try again when it\'s reachable.',
      'network': 'Couldn\'t reach $community.',
      'other': 'Something went wrong. Try again.',
    });
    return '$_temp0';
  }

  @override
  String get vtcGroupMembersOpen => 'Members';

  @override
  String vtcGroupMembersTitle(String group) {
    return 'Members of $group';
  }

  @override
  String get vtcGroupMembersNone => 'No other members to show.';

  @override
  String vtcGroupMembersUnlistedNote(String community) {
    return 'Members who chose not to be listed in the directory of $community aren\'t shown.';
  }

  @override
  String vtcDirectoryNameRefused(String community) {
    return '$community doesn\'t accept this name.';
  }

  @override
  String vtcDirectoryNameShown(String community, String name) {
    return 'Members of $community see you as $name, with the name and picture of the identity you joined with.';
  }

  @override
  String vtcTrustRecordDocument(String community) {
    return 'What $community keeps';
  }

  @override
  String get vtcVouchTrailYou => 'You';

  @override
  String vtcVouchTrailTheirVta(String name) {
    return '$name\'s VTA';
  }

  @override
  String vtcVouchTrailIn(String community) {
    return 'In $community.';
  }

  @override
  String vtcVouchTrailValidFrom(String community, String date) {
    return 'In $community, valid from $date.';
  }

  @override
  String get vtcVouchTrailVouchedFor => 'Vouched for';

  @override
  String vtcVouchTrailSignedByTheirVta(String name) {
    return 'Signed by $name\'s VTA';
  }

  @override
  String vtcVouchTrailSignedTheirSummary(String name, String community) {
    return 'As the identity $name joined $community with.';
  }

  @override
  String vtcVouchTrailStoredSummary(String community) {
    return 'Members of $community can see this vouch.';
  }

  @override
  String get vtcVouchTrailRecord => 'Record';

  @override
  String get vtcVouchTrailStoredAt => 'Stored at';

  @override
  String get vtcVouchTrailTheVouch => 'The vouch';

  @override
  String vtcTrustVouchedForEachOther(String name) {
    return 'You and $name vouched for each other';
  }

  @override
  String vtcMemberCredentialsTitle(String name) {
    return '$name\'s credentials';
  }

  @override
  String vtcMemberCredentialsNote(String community) {
    return 'As $community shows them to you.';
  }

  @override
  String vtcMemberCredentialsNone(String community, String name) {
    return '$community shows you none of $name\'s credentials.';
  }

  @override
  String get vtcMemberCredentialsMembership => 'Membership card';

  @override
  String get vtcMemberCredentialsRole => 'Role card';

  @override
  String vtcMemberCredentialsIssuedBy(String community) {
    return 'Issued by $community';
  }

  @override
  String get vtcMemberCredentialsAcknowledgement => 'Acknowledgement';

  @override
  String vtcMemberCredentialsAcknowledgementBound(String name) {
    return 'Signed by $name, for this membership card';
  }

  @override
  String vtcMemberCredentialsAcknowledgementStale(String name) {
    return 'Signed by $name, for an earlier membership card';
  }

  @override
  String get vtcMemberCredentialsPublicCard => 'Public card';

  @override
  String vtcMemberCredentialsSignedBy(String name) {
    return 'Signed by $name';
  }

  @override
  String vtcMemberCredentialsVouch(String issuer, String subject) {
    return '$issuer vouched for $subject';
  }

  @override
  String vtcMemberCredentialsStoredAt(String date) {
    return 'Stored $date';
  }

  @override
  String get vtcMemberCredentialsAnotherMember => 'another member';

  @override
  String vtcJoinAlreadyMember(String name) {
    return 'You\'re already a member of $name.';
  }

  @override
  String get vtcGroupsOpen => 'Groups';

  @override
  String get vtcRoomsOpen => 'Rooms';

  @override
  String get vtcRoomsTitle => 'Rooms';

  @override
  String get vtcRoomsNone =>
      'No rooms yet. When a group you\'re in is given a room, it\'s offered to you here.';

  @override
  String get vtcRoomsOffersHeading => 'Offered to you';

  @override
  String get vtcRoomsMineHeading => 'Your rooms';

  @override
  String get vtcRoomsAccept => 'Accept';

  @override
  String vtcRoomsAccepted(String room) {
    return 'You\'re in $room.';
  }

  @override
  String get vtcRoomsReadWrite => 'Read and write';

  @override
  String get vtcRoomsReadOnly => 'Read only';

  @override
  String get vtcRoomsClosed => 'Not open to you now';

  @override
  String get vtcRoomsSealed =>
      'Sealed: only the room\'s members can read what\'s written here.';

  @override
  String get vtcRoomsOpenTier =>
      'Open: the community hosting this room can read what\'s written here.';

  @override
  String get vtcRoomsVtaMissing => 'Link your VTA to use rooms.';

  @override
  String get vtcRoomsFailed => 'Couldn\'t reach the room. Try again.';

  @override
  String get vtcRoomRecordsNone => 'Nothing has been written here yet.';

  @override
  String get vtcRoomRecordsNoneWriter =>
      'Nothing has been written here yet. Tap Write to add the first record.';

  @override
  String get vtcRoomReadOnlyNote =>
      'You can read this room. Only members who may write can add to it.';

  @override
  String get vtcRoomRecordUnopened =>
      'This record couldn\'t be opened or its signature didn\'t check out.';

  @override
  String get vtcRoomRecordUntitled => 'Untitled';

  @override
  String get vtcRoomRecordOutdated => 'Marked as outdated';

  @override
  String get vtcRoomRecordByYou => 'Written by you';

  @override
  String get vtcRoomRecordByMember => 'Written by another member';

  @override
  String get vtcRoomWrite => 'Write';

  @override
  String get vtcRoomWriteTitle => 'New record';

  @override
  String get vtcRoomWriteTitleLabel => 'Title';

  @override
  String get vtcRoomWriteBodyLabel => 'Text';

  @override
  String get vtcRoomWriteSend => 'Post';

  @override
  String get vtcRoomWriteCancel => 'Cancel';

  @override
  String get vtcRoomWritten => 'Posted.';

  @override
  String get vtcRoomWriteRefused =>
      'You can only read this room, so you can\'t add to it.';

  @override
  String get vtcGroupsTitle => 'Groups';

  @override
  String get vtcGroupsNone => 'You\'re not in any of this community\'s groups.';

  @override
  String get vtcGroupsVtaMissing => 'Link your VTA to see your groups.';

  @override
  String get vtcGroupsNotAMember =>
      'This phone hasn\'t confirmed your membership yet. Open the community to check, then try again.';

  @override
  String get vtcGroupsUnreachable =>
      'Your groups couldn\'t be loaded. Check your connection and try again.';

  @override
  String get vtcGroupManager => 'Manager';

  @override
  String get vtcGroupChatHeading => 'Group chat';

  @override
  String get vtcGroupChatPostingTitle => 'Who can post in this chat?';

  @override
  String get vtcGroupChatPostingEveryone => 'Everyone in the group';

  @override
  String get vtcGroupChatPostingEveryoneHint => 'Every member reads and posts.';

  @override
  String get vtcGroupChatPostingManagers => 'Only the group\'s managers';

  @override
  String get vtcGroupChatPostingManagersHint =>
      'Members only read, as in announcements.';

  @override
  String get vtcGroupChatReadOnly =>
      'Only the group\'s managers post in this chat.';

  @override
  String get vtcGroupCredential => 'Group credential';

  @override
  String vtcGroupCredentialUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get vtcGroupChatUnknown => 'This group\'s chat couldn\'t be checked.';

  @override
  String get vtcGroupChatNone => 'This group has no chat yet.';

  @override
  String get vtcGroupChatLinked => 'This group has a chat you can join.';

  @override
  String get vtcGroupChatOwned =>
      'You own this group\'s chat. Members you let in appear in it.';

  @override
  String get vtcGroupChatJoined =>
      'You asked to join this group\'s chat. You\'ll find it in your chats.';

  @override
  String get vtcGroupChatCreate => 'Create chat';

  @override
  String get vtcGroupChatJoin => 'Join chat';

  @override
  String get vtcGroupChatHidesMembers =>
      'This group hides its members, so it can\'t have a chat.';

  @override
  String get vtcGroupChatNotAManager =>
      'Only a manager of this group can create its chat.';

  @override
  String get vtcGroupChatAlreadyLinked => 'This group already has a chat.';

  @override
  String get vtcGroupChatNotLinked =>
      'This group\'s chat isn\'t linked yet. Ask one of its managers.';

  @override
  String get vtcGroupChatElsewhere =>
      'This group\'s chat is on another Meeting Place.';

  @override
  String get vtcGroupChatNotTheGroups =>
      'The linked chat isn\'t this group\'s. Ask one of its managers.';

  @override
  String get vtcGroupChatMemberNotHere =>
      'The identity that is your membership of this community isn\'t on this phone.';

  @override
  String get vtcGroupChatNoCredential =>
      'Your VTA doesn\'t have this group\'s membership credential yet. Try again later.';

  @override
  String get vtcGroupChatFailed => 'That didn\'t work. Try again.';

  @override
  String get vtcGroupChatLinkTitle => 'Publish the chat\'s link';

  @override
  String get vtcGroupChatLinkBody =>
      'Members find the chat through the group\'s DID. Ask your community\'s operator to add this service to the group\'s DID document. Until then, members can\'t find the chat.';

  @override
  String get vtcGroupChatLinkCopy => 'Copy';

  @override
  String get vtcGroupChatLinkCopied => 'Copied';

  @override
  String get vtcGroupChatLinkDone => 'Done';

  @override
  String vtcCardStepFinding(String name) {
    return 'Looking on your VTA for the card $name issued you';
  }

  @override
  String get vtcCardStepReading => 'Opening your card';

  @override
  String vtcJoinVettingIntro(String name) {
    return '$name asks to meet you first. One of its vetters checks who you are, in person, and vouches for you.';
  }

  @override
  String vtcJoinVettingProgress(int have, int needed) {
    return '$have of $needed vetters vouched for you';
  }

  @override
  String vtcJoinVettingMethodNeed(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more must meet you',
      one: '1 more must meet you',
    );
    String _temp1 = intl.Intl.selectLogic(method, {
      'inPerson': 'in person',
      'video': 'over video',
      'priorAcquaintance': 'and know you already',
      'other': '',
    });
    return '$_temp0 $_temp1';
  }

  @override
  String vtcJoinVettingChecks(String claims) {
    return 'Vetters check: $claims';
  }

  @override
  String vtcJoinVettingMaxAge(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'A vouch counts for $days days',
      one: 'A vouch counts for 1 day',
    );
    return '$_temp0';
  }

  @override
  String get vtcJoinVettingNotIndependent =>
      'These vouches don\'t all count together. Ask another vetter.';

  @override
  String get vtcJoinVettersHeading => 'Your vetters';

  @override
  String vtcJoinVettingStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'requested': 'Waiting for them to answer',
      'accepted': 'Confirmed as a vetter · waiting for them to start',
      'inSession': 'Compare the match code',
      'cardSent': 'Waiting for their vouch',
      'vouched': 'Vouched for you',
      'declined': 'Declined to vouch',
      'refused': 'Couldn\'t go ahead',
      'abandoned': 'You ended the session',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String vtcJoinVettingFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'otherCommunity': 'This ticket is for another community.',
      'invalidTicket':
          'The vetter didn\'t take this ticket or code. It may have expired or been used. Ask them for a new one.',
      'unavailable': 'The vetter can\'t vet you right now.',
      'notVetter':
          'This person couldn\'t show that the community made them a vetter, so nothing was shared.',
      'vetterRevoked': 'The community no longer lets this person vet.',
      'sessionExpired':
          'The session has ended. Ask the vetter to start a new one.',
      'badAnswer':
          'The vetter\'s answer couldn\'t be checked, so it was ignored.',
      'other': 'The vetter refused.',
    });
    return '$_temp0';
  }

  @override
  String get vtcJoinVettingScanAction => 'Scan a vetter\'s ticket';

  @override
  String get vtcJoinVettingCodeAction => 'Enter a vetter\'s code';

  @override
  String get vtcJoinVettingSendAction => 'Send application';

  @override
  String get vtcJoinChooseVetterTitle => 'Who are you meeting?';

  @override
  String get vtcJoinChooseVetterIntro =>
      'Pick the vetter in front of you. Names are the vetters\' own.';

  @override
  String vtcJoinNoVetters(String name) {
    return '$name lists no vetters. Scan your vetter\'s ticket instead.';
  }

  @override
  String vtcJoinVettingCodeTitle(String vetter) {
    return 'Enter $vetter\'s code';
  }

  @override
  String get vtcJoinVettingCodeIntro =>
      'Ask them to read out the code their app shows.';

  @override
  String get vtcJoinVettingCodeHint => 'Code, e.g. K7QF-2M9X';

  @override
  String vtcJoinVettingVerified(String vetter, String name, String date) {
    return '$vetter is a vetter of $name until $date.';
  }

  @override
  String get vtcJoinMatchTitle => 'Do the codes match?';

  @override
  String vtcJoinMatchIntro(String vetter) {
    return '$vetter sees a code too. Read yours out and check it\'s the same.';
  }

  @override
  String get vtcJoinMatchYes => 'They match';

  @override
  String get vtcJoinMatchNo => 'They don\'t match';

  @override
  String vtcJoinVettingCardTitle(String vetter) {
    return 'Show these details to $vetter?';
  }

  @override
  String vtcJoinVettingCardNote(String vetter) {
    return 'Only $vetter sees these. They check them against your ID, and the community gets their vouch, not your details.';
  }

  @override
  String get vtcJoinVettingCardDecline => 'Don\'t share';

  @override
  String get vtcJoinMatchCodeHeading => 'Your match code';

  @override
  String get vtcJoinVettingCardHeading => 'Details for your vetter';

  @override
  String get vtcVetterStart => 'Vet applicants';

  @override
  String vtcVetterTitle(String name) {
    return 'Vetting for $name';
  }

  @override
  String get vtcVetterIntro =>
      'Show your ticket to someone who wants to join. You\'ll check their details in person.';

  @override
  String vtcVetterNotVetter(String name) {
    return 'You can\'t vet for $name right now: your vetter card has expired or been withdrawn.';
  }

  @override
  String get vtcVetterTicketHeading => 'Your vetting ticket';

  @override
  String get vtcVetterTicketCodeHint => 'Or read out this code';

  @override
  String vtcVetterTicketValid(String time) {
    return 'Good for one applicant, until $time.';
  }

  @override
  String get vtcVetterNewTicket => 'New ticket';

  @override
  String get vtcVetterShowTicket => 'Show a vetting ticket';

  @override
  String get vtcVetterWaiting =>
      'Waiting for someone to scan the ticket or enter the code…';

  @override
  String get vtcVetterMatchIntro =>
      'The applicant sees a code too. Ask them to read theirs out and check it\'s the same.';

  @override
  String get vtcVetterCardWaiting => 'Waiting for the applicant\'s details…';

  @override
  String get vtcVetterCardHeading => 'Applicant\'s details';

  @override
  String get vtcVetterCardIntro =>
      'Check these details against their ID document, with them in front of you.';

  @override
  String get vtcVetterDocumentHeading => 'Document you checked';

  @override
  String vtcVetterDocument(String document) {
    String _temp0 = intl.Intl.selectLogic(document, {
      'passport': 'Passport',
      'nationalId': 'National ID card',
      'driverLicence': 'Driving licence',
      'other': '$document',
    });
    return '$_temp0';
  }

  @override
  String get vtcVetterCheckedInPerson =>
      'I checked these details against the document, with the applicant in front of me.';

  @override
  String get vtcVetterIssue => 'Vouch for them';

  @override
  String get vtcVetterDecline => 'Decline';

  @override
  String get vtcVetterIssuedHeading => 'Statements you issued';

  @override
  String vtcVetterIssuedLine(String date, String until) {
    return 'Issued $date, valid until $until';
  }

  @override
  String get vtcVetterIssuedNone => 'None yet.';

  @override
  String vtcVetterFailure(String failure) {
    String _temp0 = intl.Intl.selectLogic(failure, {
      'notVetter': 'Your vetter card is no longer valid.',
      'other': 'Something went wrong. Check your connection and try again.',
    });
    return '$_temp0';
  }

  @override
  String onboardingStepOf(int step, int total, String title) {
    return 'Step $step of $total · $title';
  }

  @override
  String get vtcVetterResume => 'Continue vetting';

  @override
  String vtcVettingFlowStep(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'ticket': 'Show your ticket',
      'match': 'Compare codes',
      'details': 'Check their details',
      'other': 'Done',
    });
    return '$_temp0';
  }

  @override
  String vtcVetterOutcome(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'issued': 'You vouched for them. They now hold your statement.',
      'declined': 'You declined to vouch for them.',
      'other': 'The applicant ended the session.',
    });
    return '$_temp0';
  }

  @override
  String get vtcVetterBackToDesk => 'Back to the desk';

  @override
  String vtcApplicantStep(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'meet': 'Meet a vetter',
      'ticket': 'Ask the vetter',
      'match': 'Compare codes',
      'details': 'Share your details',
      'other': 'Done',
    });
    return '$_temp0';
  }

  @override
  String vtcApplicantListingVetters(String name) {
    return 'Getting $name\'s vetters';
  }

  @override
  String get vtcApplicantUnlocking => 'Getting your identity ready';

  @override
  String vtcApplicantSendingRequest(String vetter) {
    return 'Sending your request to $vetter';
  }

  @override
  String vtcApplicantWaitingSession(String vetter) {
    return 'Waiting for $vetter to open a session';
  }

  @override
  String get vtcApplicantPreparing =>
      'Getting the details they check from your VTA';

  @override
  String get vtcApplicantRecording => 'Recording what you share on your VTA';

  @override
  String vtcApplicantSendingDetails(String vetter) {
    return 'Sending your details to $vetter';
  }

  @override
  String vtcApplicantWaitingCheck(String vetter) {
    return 'Waiting for $vetter to check your details';
  }

  @override
  String vtcApplicantOutcome(String status, String vetter) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'vouched': '$vetter vouched for you',
      'declined': '$vetter declined to vouch for you',
      'refused': '$vetter couldn\'t take your request',
      'unanswered': 'No answer from $vetter. Ask them for a new ticket.',
      'other': 'You ended the session with $vetter',
    });
    return '$_temp0';
  }

  @override
  String get vtcApplicantBackToOverview => 'Back to the overview';

  @override
  String get vtcVetterCardTitle => 'Vetter card';

  @override
  String get vtcVetterCardHolder => 'Vetter';

  @override
  String get vtcVetterStepCard => 'Checking your vetter card is still valid';

  @override
  String get vtcVetterApplicantFound => 'An applicant scanned your ticket';

  @override
  String get vtcVetterStepSession => 'Opening a session with them';

  @override
  String get vtcBackgroundHeading => 'In the background';

  @override
  String get vtcVetterStepTicket => 'Creating your ticket';

  @override
  String vtcVetterStepRequirements(String name) {
    return 'Getting what $name asks you to check';
  }

  @override
  String get vtcVetterCheckFailed =>
      'Couldn\'t check your vetter card, so vetting isn\'t offered. Try again later.';

  @override
  String vtcVetterRequirementsHeading(String name) {
    return 'What $name asks you to check';
  }

  @override
  String vtcVetterRequirementsDocuments(String documents) {
    return 'Accepted documents: $documents';
  }

  @override
  String get vtcVetterRequirementsInPerson =>
      'Check each detail against an ID document, with the applicant in front of you.';

  @override
  String get vtcJoinVettingStopAction => 'Stop vetting';

  @override
  String vtcJoinVettingStopTitle(String name) {
    return 'Stop vetting for $name?';
  }

  @override
  String get vtcJoinVettingStopMessage =>
      'The vetters\' statements and open requests on this phone are forgotten. You can start again from the community\'s page.';

  @override
  String vtcJoinVettingDetailsMissing(String identity, String details) {
    return '$identity has no $details on your VTA, so nothing was sent. Add them to its profile, or stop vetting and choose another identity.';
  }

  @override
  String vtcJoinApplyingIdentityNamed(String name) {
    return 'Your identity $name';
  }

  @override
  String get vtcJoinApplyingIdentityCreated =>
      'The identity your VTA created for this community';

  @override
  String vtcJoinVetterListedAs(String name) {
    return 'Listed as $name';
  }

  @override
  String get vtcVetterProfileTitle => 'Your vetter profile';

  @override
  String get vtcVetterProfileOpen => 'Your vetter profile';

  @override
  String vtcVetterProfileIntro(String name) {
    return 'People applying to $name who look for a vetter see what you write here, as your own words. Nobody checks it.';
  }

  @override
  String get vtcVetterProfileListed => 'List me for applicants';

  @override
  String get vtcVetterProfileListedNote =>
      'Off keeps your profile with the community but out of its list.';

  @override
  String get vtcVetterProfileStoredListed =>
      'Your profile is in the community\'s list.';

  @override
  String get vtcVetterProfileStoredHidden =>
      'The community keeps your profile, but doesn\'t list it.';

  @override
  String get vtcVetterProfileDisplayName => 'Name to be listed under';

  @override
  String get vtcVetterProfileLanguages => 'Languages you vet in, e.g. en, de';

  @override
  String get vtcVetterProfileCountry => 'Country code, e.g. DE';

  @override
  String get vtcVetterProfileCity => 'City (needs a country)';

  @override
  String get vtcVetterProfileContactHint =>
      'How applicants get a ticket from you';

  @override
  String get vtcVetterProfileAvailability => 'When you\'re available';

  @override
  String get vtcVetterProfileMethodsHeading => 'How you vet';

  @override
  String vtcVetterProfileMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'inPerson': 'In person',
      'video': 'On a video call',
      'priorAcquaintance': 'People I already know',
      'other': '$method',
    });
    return '$_temp0';
  }

  @override
  String get vtcVetterProfileDocumentsHeading => 'Documents you accept';

  @override
  String get vtcVetterProfileNoDocument => 'None: I know the person';

  @override
  String get vtcVetterProfilePublish => 'Publish';

  @override
  String vtcVetterProfileInvalid(String reason) {
    return 'The community would refuse this profile ($reason).';
  }

  @override
  String get vtcVetterProfileNeeded =>
      'Applicants can\'t find you yet. Set up your vetter profile so they know how to reach you.';

  @override
  String get vtcVetterProfileSetUp => 'Set up your vetter profile';

  @override
  String get vtcVetterUnnamed => 'Unnamed vetter';

  @override
  String vtcVetterDetailsMethods(String methods) {
    return 'How they vet: $methods';
  }

  @override
  String vtcVetterDetailsMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'inPerson': 'in person',
      'video': 'on a video call',
      'priorAcquaintance': 'people they already know',
      'other': '$method',
    });
    return '$_temp0';
  }

  @override
  String vtcVetterDetailsLanguages(String languages) {
    return 'Languages: $languages';
  }

  @override
  String vtcVetterDetailsPlace(String place) {
    return 'Where: $place';
  }

  @override
  String vtcVetterDetailsDocuments(String documents) {
    return 'Documents: $documents';
  }

  @override
  String get vtcVetterDetailsNoDocument => 'none, they know you';

  @override
  String vtcVetterDetailsAvailability(String availability) {
    return 'Available: $availability';
  }

  @override
  String vtcVetterDetailsContactHint(String hint) {
    return 'Getting a ticket: $hint';
  }

  @override
  String vtcVetterDetailsEvents(String events) {
    return 'Events: $events';
  }

  @override
  String vtcVetterDetailsDid(String did) {
    return 'DID: $did';
  }

  @override
  String get communitiesSubtitle => 'Tap a community to see its channels.';

  @override
  String get communitiesNone => 'You have not joined a community yet.';

  @override
  String get communityPending => 'Pending';

  @override
  String get communityChannelsTab => 'Channels';

  @override
  String get communityMembersTab => 'Members';

  @override
  String communityMembersPrompt(String community) {
    return 'Members of your groups are shown. Search the directory of $community to find others.';
  }
}
