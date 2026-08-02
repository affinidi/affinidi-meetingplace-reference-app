// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: const Uuid().v4,
  );
  static const VerificationMeta _channelDidMeta = const VerificationMeta(
    'channelDid',
  );
  @override
  late final GeneratedColumn<String> channelDid = GeneratedColumn<String>(
    'channel_did',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelDidSha256Meta = const VerificationMeta(
    'channelDidSha256',
  );
  @override
  late final GeneratedColumn<String> channelDidSha256 = GeneratedColumn<String>(
    'channel_did_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: clock.now,
  );
  static const VerificationMeta _offerLinkMeta = const VerificationMeta(
    'offerLink',
  );
  @override
  late final GeneratedColumn<String> offerLink = GeneratedColumn<String>(
    'offer_link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediatorDidMeta = const VerificationMeta(
    'mediatorDid',
  );
  @override
  late final GeneratedColumn<String> mediatorDid = GeneratedColumn<String>(
    'mediator_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ContactType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ContactType>($ContactsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<ContactStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ContactStatus>($ContactsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<ContactOrigin, int> origin =
      GeneratedColumn<int>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ContactOrigin>($ContactsTable.$converterorigin);
  @override
  late final GeneratedColumnWithTypeConverter<ContactCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ContactCategory>($ContactsTable.$convertercategory);
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _badgeUpdateInProgressMeta =
      const VerificationMeta('badgeUpdateInProgress');
  @override
  late final GeneratedColumn<bool> badgeUpdateInProgress =
      GeneratedColumn<bool>(
        'badge_update_in_progress',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("badge_update_in_progress" IN (0, 1))',
        ),
        clientDefault: () => false,
      );
  static const VerificationMeta _badgeCountMeta = const VerificationMeta(
    'badgeCount',
  );
  @override
  late final GeneratedColumn<int> badgeCount = GeneratedColumn<int>(
    'badge_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _currentMessageSeqNoMeta =
      const VerificationMeta('currentMessageSeqNo');
  @override
  late final GeneratedColumn<int> currentMessageSeqNo = GeneratedColumn<int>(
    'current_message_seq_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _missedCallCountMeta = const VerificationMeta(
    'missedCallCount',
  );
  @override
  late final GeneratedColumn<int> missedCallCount = GeneratedColumn<int>(
    'missed_call_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _pendingMissedCallAtMeta =
      const VerificationMeta('pendingMissedCallAt');
  @override
  late final GeneratedColumn<DateTime> pendingMissedCallAt =
      GeneratedColumn<DateTime>(
        'pending_missed_call_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pendingMissedCallIdMeta =
      const VerificationMeta('pendingMissedCallId');
  @override
  late final GeneratedColumn<String> pendingMissedCallId =
      GeneratedColumn<String>(
        'pending_missed_call_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _activeIncomingCallIdMeta =
      const VerificationMeta('activeIncomingCallId');
  @override
  late final GeneratedColumn<String> activeIncomingCallId =
      GeneratedColumn<String>(
        'active_incoming_call_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hasBeenOpenedMeta = const VerificationMeta(
    'hasBeenOpened',
  );
  @override
  late final GeneratedColumn<bool> hasBeenOpened = GeneratedColumn<bool>(
    'has_been_opened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_been_opened" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  static const VerificationMeta _lastKeepAliveMessageMeta =
      const VerificationMeta('lastKeepAliveMessage');
  @override
  late final GeneratedColumn<DateTime> lastKeepAliveMessage =
      GeneratedColumn<DateTime>(
        'last_keep_alive_message',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationBannerDismissedMeta =
      const VerificationMeta('notificationBannerDismissed');
  @override
  late final GeneratedColumn<bool> notificationBannerDismissed =
      GeneratedColumn<bool>(
        'notification_banner_dismissed',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_banner_dismissed" IN (0, 1))',
        ),
        clientDefault: () => false,
      );
  static const VerificationMeta _personalAgentAuthorizationSnapshotMeta =
      const VerificationMeta('personalAgentAuthorizationSnapshot');
  @override
  late final GeneratedColumn<String> personalAgentAuthorizationSnapshot =
      GeneratedColumn<String>(
        'personal_agent_authorization_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    channelDid,
    channelDidSha256,
    dateAdded,
    offerLink,
    mediatorDid,
    type,
    status,
    origin,
    category,
    displayName,
    badgeUpdateInProgress,
    badgeCount,
    currentMessageSeqNo,
    missedCallCount,
    pendingMissedCallAt,
    pendingMissedCallId,
    activeIncomingCallId,
    hasBeenOpened,
    lastKeepAliveMessage,
    notificationBannerDismissed,
    personalAgentAuthorizationSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('channel_did')) {
      context.handle(
        _channelDidMeta,
        channelDid.isAcceptableOrUnknown(data['channel_did']!, _channelDidMeta),
      );
    }
    if (data.containsKey('channel_did_sha256')) {
      context.handle(
        _channelDidSha256Meta,
        channelDidSha256.isAcceptableOrUnknown(
          data['channel_did_sha256']!,
          _channelDidSha256Meta,
        ),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    if (data.containsKey('offer_link')) {
      context.handle(
        _offerLinkMeta,
        offerLink.isAcceptableOrUnknown(data['offer_link']!, _offerLinkMeta),
      );
    } else if (isInserting) {
      context.missing(_offerLinkMeta);
    }
    if (data.containsKey('mediator_did')) {
      context.handle(
        _mediatorDidMeta,
        mediatorDid.isAcceptableOrUnknown(
          data['mediator_did']!,
          _mediatorDidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediatorDidMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('badge_update_in_progress')) {
      context.handle(
        _badgeUpdateInProgressMeta,
        badgeUpdateInProgress.isAcceptableOrUnknown(
          data['badge_update_in_progress']!,
          _badgeUpdateInProgressMeta,
        ),
      );
    }
    if (data.containsKey('badge_count')) {
      context.handle(
        _badgeCountMeta,
        badgeCount.isAcceptableOrUnknown(data['badge_count']!, _badgeCountMeta),
      );
    }
    if (data.containsKey('current_message_seq_no')) {
      context.handle(
        _currentMessageSeqNoMeta,
        currentMessageSeqNo.isAcceptableOrUnknown(
          data['current_message_seq_no']!,
          _currentMessageSeqNoMeta,
        ),
      );
    }
    if (data.containsKey('missed_call_count')) {
      context.handle(
        _missedCallCountMeta,
        missedCallCount.isAcceptableOrUnknown(
          data['missed_call_count']!,
          _missedCallCountMeta,
        ),
      );
    }
    if (data.containsKey('pending_missed_call_at')) {
      context.handle(
        _pendingMissedCallAtMeta,
        pendingMissedCallAt.isAcceptableOrUnknown(
          data['pending_missed_call_at']!,
          _pendingMissedCallAtMeta,
        ),
      );
    }
    if (data.containsKey('pending_missed_call_id')) {
      context.handle(
        _pendingMissedCallIdMeta,
        pendingMissedCallId.isAcceptableOrUnknown(
          data['pending_missed_call_id']!,
          _pendingMissedCallIdMeta,
        ),
      );
    }
    if (data.containsKey('active_incoming_call_id')) {
      context.handle(
        _activeIncomingCallIdMeta,
        activeIncomingCallId.isAcceptableOrUnknown(
          data['active_incoming_call_id']!,
          _activeIncomingCallIdMeta,
        ),
      );
    }
    if (data.containsKey('has_been_opened')) {
      context.handle(
        _hasBeenOpenedMeta,
        hasBeenOpened.isAcceptableOrUnknown(
          data['has_been_opened']!,
          _hasBeenOpenedMeta,
        ),
      );
    }
    if (data.containsKey('last_keep_alive_message')) {
      context.handle(
        _lastKeepAliveMessageMeta,
        lastKeepAliveMessage.isAcceptableOrUnknown(
          data['last_keep_alive_message']!,
          _lastKeepAliveMessageMeta,
        ),
      );
    }
    if (data.containsKey('notification_banner_dismissed')) {
      context.handle(
        _notificationBannerDismissedMeta,
        notificationBannerDismissed.isAcceptableOrUnknown(
          data['notification_banner_dismissed']!,
          _notificationBannerDismissedMeta,
        ),
      );
    }
    if (data.containsKey('personal_agent_authorization_snapshot')) {
      context.handle(
        _personalAgentAuthorizationSnapshotMeta,
        personalAgentAuthorizationSnapshot.isAcceptableOrUnknown(
          data['personal_agent_authorization_snapshot']!,
          _personalAgentAuthorizationSnapshotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      channelDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_did'],
      ),
      channelDidSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_did_sha256'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      offerLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offer_link'],
      )!,
      mediatorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mediator_did'],
      )!,
      type: $ContactsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $ContactsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      origin: $ContactsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}origin'],
        )!,
      ),
      category: $ContactsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      badgeUpdateInProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}badge_update_in_progress'],
      )!,
      badgeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}badge_count'],
      )!,
      currentMessageSeqNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_message_seq_no'],
      )!,
      missedCallCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}missed_call_count'],
      )!,
      pendingMissedCallAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pending_missed_call_at'],
      ),
      pendingMissedCallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_missed_call_id'],
      ),
      activeIncomingCallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_incoming_call_id'],
      ),
      hasBeenOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_been_opened'],
      )!,
      lastKeepAliveMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_keep_alive_message'],
      ),
      notificationBannerDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_banner_dismissed'],
      )!,
      personalAgentAuthorizationSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_agent_authorization_snapshot'],
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }

  static TypeConverter<ContactType, int> $convertertype =
      const _ContactTypeConverter();
  static TypeConverter<ContactStatus, int> $converterstatus =
      const _ContactStatusConverter();
  static TypeConverter<ContactOrigin, int> $converterorigin =
      const _ContactOriginConverter();
  static TypeConverter<ContactCategory, int> $convertercategory =
      const _ContactCategoryConverter();
}

class Contact extends DataClass implements Insertable<Contact> {
  final String id;
  final String? channelDid;
  final String? channelDidSha256;
  final DateTime dateAdded;
  final String offerLink;
  final String mediatorDid;
  final ContactType type;
  final ContactStatus status;
  final ContactOrigin origin;
  final ContactCategory category;
  final String? displayName;
  final bool badgeUpdateInProgress;
  final int badgeCount;
  final int currentMessageSeqNo;
  final int missedCallCount;
  final DateTime? pendingMissedCallAt;
  final String? pendingMissedCallId;
  final String? activeIncomingCallId;
  final bool hasBeenOpened;
  final DateTime? lastKeepAliveMessage;
  final bool notificationBannerDismissed;
  final String? personalAgentAuthorizationSnapshot;
  const Contact({
    required this.id,
    this.channelDid,
    this.channelDidSha256,
    required this.dateAdded,
    required this.offerLink,
    required this.mediatorDid,
    required this.type,
    required this.status,
    required this.origin,
    required this.category,
    this.displayName,
    required this.badgeUpdateInProgress,
    required this.badgeCount,
    required this.currentMessageSeqNo,
    required this.missedCallCount,
    this.pendingMissedCallAt,
    this.pendingMissedCallId,
    this.activeIncomingCallId,
    required this.hasBeenOpened,
    this.lastKeepAliveMessage,
    required this.notificationBannerDismissed,
    this.personalAgentAuthorizationSnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || channelDid != null) {
      map['channel_did'] = Variable<String>(channelDid);
    }
    if (!nullToAbsent || channelDidSha256 != null) {
      map['channel_did_sha256'] = Variable<String>(channelDidSha256);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['offer_link'] = Variable<String>(offerLink);
    map['mediator_did'] = Variable<String>(mediatorDid);
    {
      map['type'] = Variable<int>($ContactsTable.$convertertype.toSql(type));
    }
    {
      map['status'] = Variable<int>(
        $ContactsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['origin'] = Variable<int>(
        $ContactsTable.$converterorigin.toSql(origin),
      );
    }
    {
      map['category'] = Variable<int>(
        $ContactsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['badge_update_in_progress'] = Variable<bool>(badgeUpdateInProgress);
    map['badge_count'] = Variable<int>(badgeCount);
    map['current_message_seq_no'] = Variable<int>(currentMessageSeqNo);
    map['missed_call_count'] = Variable<int>(missedCallCount);
    if (!nullToAbsent || pendingMissedCallAt != null) {
      map['pending_missed_call_at'] = Variable<DateTime>(pendingMissedCallAt);
    }
    if (!nullToAbsent || pendingMissedCallId != null) {
      map['pending_missed_call_id'] = Variable<String>(pendingMissedCallId);
    }
    if (!nullToAbsent || activeIncomingCallId != null) {
      map['active_incoming_call_id'] = Variable<String>(activeIncomingCallId);
    }
    map['has_been_opened'] = Variable<bool>(hasBeenOpened);
    if (!nullToAbsent || lastKeepAliveMessage != null) {
      map['last_keep_alive_message'] = Variable<DateTime>(lastKeepAliveMessage);
    }
    map['notification_banner_dismissed'] = Variable<bool>(
      notificationBannerDismissed,
    );
    if (!nullToAbsent || personalAgentAuthorizationSnapshot != null) {
      map['personal_agent_authorization_snapshot'] = Variable<String>(
        personalAgentAuthorizationSnapshot,
      );
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      channelDid: channelDid == null && nullToAbsent
          ? const Value.absent()
          : Value(channelDid),
      channelDidSha256: channelDidSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(channelDidSha256),
      dateAdded: Value(dateAdded),
      offerLink: Value(offerLink),
      mediatorDid: Value(mediatorDid),
      type: Value(type),
      status: Value(status),
      origin: Value(origin),
      category: Value(category),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      badgeUpdateInProgress: Value(badgeUpdateInProgress),
      badgeCount: Value(badgeCount),
      currentMessageSeqNo: Value(currentMessageSeqNo),
      missedCallCount: Value(missedCallCount),
      pendingMissedCallAt: pendingMissedCallAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingMissedCallAt),
      pendingMissedCallId: pendingMissedCallId == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingMissedCallId),
      activeIncomingCallId: activeIncomingCallId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeIncomingCallId),
      hasBeenOpened: Value(hasBeenOpened),
      lastKeepAliveMessage: lastKeepAliveMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKeepAliveMessage),
      notificationBannerDismissed: Value(notificationBannerDismissed),
      personalAgentAuthorizationSnapshot:
          personalAgentAuthorizationSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(personalAgentAuthorizationSnapshot),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<String>(json['id']),
      channelDid: serializer.fromJson<String?>(json['channelDid']),
      channelDidSha256: serializer.fromJson<String?>(json['channelDidSha256']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      offerLink: serializer.fromJson<String>(json['offerLink']),
      mediatorDid: serializer.fromJson<String>(json['mediatorDid']),
      type: serializer.fromJson<ContactType>(json['type']),
      status: serializer.fromJson<ContactStatus>(json['status']),
      origin: serializer.fromJson<ContactOrigin>(json['origin']),
      category: serializer.fromJson<ContactCategory>(json['category']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      badgeUpdateInProgress: serializer.fromJson<bool>(
        json['badgeUpdateInProgress'],
      ),
      badgeCount: serializer.fromJson<int>(json['badgeCount']),
      currentMessageSeqNo: serializer.fromJson<int>(
        json['currentMessageSeqNo'],
      ),
      missedCallCount: serializer.fromJson<int>(json['missedCallCount']),
      pendingMissedCallAt: serializer.fromJson<DateTime?>(
        json['pendingMissedCallAt'],
      ),
      pendingMissedCallId: serializer.fromJson<String?>(
        json['pendingMissedCallId'],
      ),
      activeIncomingCallId: serializer.fromJson<String?>(
        json['activeIncomingCallId'],
      ),
      hasBeenOpened: serializer.fromJson<bool>(json['hasBeenOpened']),
      lastKeepAliveMessage: serializer.fromJson<DateTime?>(
        json['lastKeepAliveMessage'],
      ),
      notificationBannerDismissed: serializer.fromJson<bool>(
        json['notificationBannerDismissed'],
      ),
      personalAgentAuthorizationSnapshot: serializer.fromJson<String?>(
        json['personalAgentAuthorizationSnapshot'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'channelDid': serializer.toJson<String?>(channelDid),
      'channelDidSha256': serializer.toJson<String?>(channelDidSha256),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'offerLink': serializer.toJson<String>(offerLink),
      'mediatorDid': serializer.toJson<String>(mediatorDid),
      'type': serializer.toJson<ContactType>(type),
      'status': serializer.toJson<ContactStatus>(status),
      'origin': serializer.toJson<ContactOrigin>(origin),
      'category': serializer.toJson<ContactCategory>(category),
      'displayName': serializer.toJson<String?>(displayName),
      'badgeUpdateInProgress': serializer.toJson<bool>(badgeUpdateInProgress),
      'badgeCount': serializer.toJson<int>(badgeCount),
      'currentMessageSeqNo': serializer.toJson<int>(currentMessageSeqNo),
      'missedCallCount': serializer.toJson<int>(missedCallCount),
      'pendingMissedCallAt': serializer.toJson<DateTime?>(pendingMissedCallAt),
      'pendingMissedCallId': serializer.toJson<String?>(pendingMissedCallId),
      'activeIncomingCallId': serializer.toJson<String?>(activeIncomingCallId),
      'hasBeenOpened': serializer.toJson<bool>(hasBeenOpened),
      'lastKeepAliveMessage': serializer.toJson<DateTime?>(
        lastKeepAliveMessage,
      ),
      'notificationBannerDismissed': serializer.toJson<bool>(
        notificationBannerDismissed,
      ),
      'personalAgentAuthorizationSnapshot': serializer.toJson<String?>(
        personalAgentAuthorizationSnapshot,
      ),
    };
  }

  Contact copyWith({
    String? id,
    Value<String?> channelDid = const Value.absent(),
    Value<String?> channelDidSha256 = const Value.absent(),
    DateTime? dateAdded,
    String? offerLink,
    String? mediatorDid,
    ContactType? type,
    ContactStatus? status,
    ContactOrigin? origin,
    ContactCategory? category,
    Value<String?> displayName = const Value.absent(),
    bool? badgeUpdateInProgress,
    int? badgeCount,
    int? currentMessageSeqNo,
    int? missedCallCount,
    Value<DateTime?> pendingMissedCallAt = const Value.absent(),
    Value<String?> pendingMissedCallId = const Value.absent(),
    Value<String?> activeIncomingCallId = const Value.absent(),
    bool? hasBeenOpened,
    Value<DateTime?> lastKeepAliveMessage = const Value.absent(),
    bool? notificationBannerDismissed,
    Value<String?> personalAgentAuthorizationSnapshot = const Value.absent(),
  }) => Contact(
    id: id ?? this.id,
    channelDid: channelDid.present ? channelDid.value : this.channelDid,
    channelDidSha256: channelDidSha256.present
        ? channelDidSha256.value
        : this.channelDidSha256,
    dateAdded: dateAdded ?? this.dateAdded,
    offerLink: offerLink ?? this.offerLink,
    mediatorDid: mediatorDid ?? this.mediatorDid,
    type: type ?? this.type,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    category: category ?? this.category,
    displayName: displayName.present ? displayName.value : this.displayName,
    badgeUpdateInProgress: badgeUpdateInProgress ?? this.badgeUpdateInProgress,
    badgeCount: badgeCount ?? this.badgeCount,
    currentMessageSeqNo: currentMessageSeqNo ?? this.currentMessageSeqNo,
    missedCallCount: missedCallCount ?? this.missedCallCount,
    pendingMissedCallAt: pendingMissedCallAt.present
        ? pendingMissedCallAt.value
        : this.pendingMissedCallAt,
    pendingMissedCallId: pendingMissedCallId.present
        ? pendingMissedCallId.value
        : this.pendingMissedCallId,
    activeIncomingCallId: activeIncomingCallId.present
        ? activeIncomingCallId.value
        : this.activeIncomingCallId,
    hasBeenOpened: hasBeenOpened ?? this.hasBeenOpened,
    lastKeepAliveMessage: lastKeepAliveMessage.present
        ? lastKeepAliveMessage.value
        : this.lastKeepAliveMessage,
    notificationBannerDismissed:
        notificationBannerDismissed ?? this.notificationBannerDismissed,
    personalAgentAuthorizationSnapshot:
        personalAgentAuthorizationSnapshot.present
        ? personalAgentAuthorizationSnapshot.value
        : this.personalAgentAuthorizationSnapshot,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      channelDid: data.channelDid.present
          ? data.channelDid.value
          : this.channelDid,
      channelDidSha256: data.channelDidSha256.present
          ? data.channelDidSha256.value
          : this.channelDidSha256,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      offerLink: data.offerLink.present ? data.offerLink.value : this.offerLink,
      mediatorDid: data.mediatorDid.present
          ? data.mediatorDid.value
          : this.mediatorDid,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      category: data.category.present ? data.category.value : this.category,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      badgeUpdateInProgress: data.badgeUpdateInProgress.present
          ? data.badgeUpdateInProgress.value
          : this.badgeUpdateInProgress,
      badgeCount: data.badgeCount.present
          ? data.badgeCount.value
          : this.badgeCount,
      currentMessageSeqNo: data.currentMessageSeqNo.present
          ? data.currentMessageSeqNo.value
          : this.currentMessageSeqNo,
      missedCallCount: data.missedCallCount.present
          ? data.missedCallCount.value
          : this.missedCallCount,
      pendingMissedCallAt: data.pendingMissedCallAt.present
          ? data.pendingMissedCallAt.value
          : this.pendingMissedCallAt,
      pendingMissedCallId: data.pendingMissedCallId.present
          ? data.pendingMissedCallId.value
          : this.pendingMissedCallId,
      activeIncomingCallId: data.activeIncomingCallId.present
          ? data.activeIncomingCallId.value
          : this.activeIncomingCallId,
      hasBeenOpened: data.hasBeenOpened.present
          ? data.hasBeenOpened.value
          : this.hasBeenOpened,
      lastKeepAliveMessage: data.lastKeepAliveMessage.present
          ? data.lastKeepAliveMessage.value
          : this.lastKeepAliveMessage,
      notificationBannerDismissed: data.notificationBannerDismissed.present
          ? data.notificationBannerDismissed.value
          : this.notificationBannerDismissed,
      personalAgentAuthorizationSnapshot:
          data.personalAgentAuthorizationSnapshot.present
          ? data.personalAgentAuthorizationSnapshot.value
          : this.personalAgentAuthorizationSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('channelDid: $channelDid, ')
          ..write('channelDidSha256: $channelDidSha256, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('offerLink: $offerLink, ')
          ..write('mediatorDid: $mediatorDid, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('category: $category, ')
          ..write('displayName: $displayName, ')
          ..write('badgeUpdateInProgress: $badgeUpdateInProgress, ')
          ..write('badgeCount: $badgeCount, ')
          ..write('currentMessageSeqNo: $currentMessageSeqNo, ')
          ..write('missedCallCount: $missedCallCount, ')
          ..write('pendingMissedCallAt: $pendingMissedCallAt, ')
          ..write('pendingMissedCallId: $pendingMissedCallId, ')
          ..write('activeIncomingCallId: $activeIncomingCallId, ')
          ..write('hasBeenOpened: $hasBeenOpened, ')
          ..write('lastKeepAliveMessage: $lastKeepAliveMessage, ')
          ..write('notificationBannerDismissed: $notificationBannerDismissed, ')
          ..write(
            'personalAgentAuthorizationSnapshot: $personalAgentAuthorizationSnapshot',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    channelDid,
    channelDidSha256,
    dateAdded,
    offerLink,
    mediatorDid,
    type,
    status,
    origin,
    category,
    displayName,
    badgeUpdateInProgress,
    badgeCount,
    currentMessageSeqNo,
    missedCallCount,
    pendingMissedCallAt,
    pendingMissedCallId,
    activeIncomingCallId,
    hasBeenOpened,
    lastKeepAliveMessage,
    notificationBannerDismissed,
    personalAgentAuthorizationSnapshot,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.channelDid == this.channelDid &&
          other.channelDidSha256 == this.channelDidSha256 &&
          other.dateAdded == this.dateAdded &&
          other.offerLink == this.offerLink &&
          other.mediatorDid == this.mediatorDid &&
          other.type == this.type &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.category == this.category &&
          other.displayName == this.displayName &&
          other.badgeUpdateInProgress == this.badgeUpdateInProgress &&
          other.badgeCount == this.badgeCount &&
          other.currentMessageSeqNo == this.currentMessageSeqNo &&
          other.missedCallCount == this.missedCallCount &&
          other.pendingMissedCallAt == this.pendingMissedCallAt &&
          other.pendingMissedCallId == this.pendingMissedCallId &&
          other.activeIncomingCallId == this.activeIncomingCallId &&
          other.hasBeenOpened == this.hasBeenOpened &&
          other.lastKeepAliveMessage == this.lastKeepAliveMessage &&
          other.notificationBannerDismissed ==
              this.notificationBannerDismissed &&
          other.personalAgentAuthorizationSnapshot ==
              this.personalAgentAuthorizationSnapshot);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> id;
  final Value<String?> channelDid;
  final Value<String?> channelDidSha256;
  final Value<DateTime> dateAdded;
  final Value<String> offerLink;
  final Value<String> mediatorDid;
  final Value<ContactType> type;
  final Value<ContactStatus> status;
  final Value<ContactOrigin> origin;
  final Value<ContactCategory> category;
  final Value<String?> displayName;
  final Value<bool> badgeUpdateInProgress;
  final Value<int> badgeCount;
  final Value<int> currentMessageSeqNo;
  final Value<int> missedCallCount;
  final Value<DateTime?> pendingMissedCallAt;
  final Value<String?> pendingMissedCallId;
  final Value<String?> activeIncomingCallId;
  final Value<bool> hasBeenOpened;
  final Value<DateTime?> lastKeepAliveMessage;
  final Value<bool> notificationBannerDismissed;
  final Value<String?> personalAgentAuthorizationSnapshot;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.channelDid = const Value.absent(),
    this.channelDidSha256 = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.offerLink = const Value.absent(),
    this.mediatorDid = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.category = const Value.absent(),
    this.displayName = const Value.absent(),
    this.badgeUpdateInProgress = const Value.absent(),
    this.badgeCount = const Value.absent(),
    this.currentMessageSeqNo = const Value.absent(),
    this.missedCallCount = const Value.absent(),
    this.pendingMissedCallAt = const Value.absent(),
    this.pendingMissedCallId = const Value.absent(),
    this.activeIncomingCallId = const Value.absent(),
    this.hasBeenOpened = const Value.absent(),
    this.lastKeepAliveMessage = const Value.absent(),
    this.notificationBannerDismissed = const Value.absent(),
    this.personalAgentAuthorizationSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    this.channelDid = const Value.absent(),
    this.channelDidSha256 = const Value.absent(),
    this.dateAdded = const Value.absent(),
    required String offerLink,
    required String mediatorDid,
    required ContactType type,
    required ContactStatus status,
    required ContactOrigin origin,
    required ContactCategory category,
    this.displayName = const Value.absent(),
    this.badgeUpdateInProgress = const Value.absent(),
    this.badgeCount = const Value.absent(),
    this.currentMessageSeqNo = const Value.absent(),
    this.missedCallCount = const Value.absent(),
    this.pendingMissedCallAt = const Value.absent(),
    this.pendingMissedCallId = const Value.absent(),
    this.activeIncomingCallId = const Value.absent(),
    this.hasBeenOpened = const Value.absent(),
    this.lastKeepAliveMessage = const Value.absent(),
    this.notificationBannerDismissed = const Value.absent(),
    this.personalAgentAuthorizationSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : offerLink = Value(offerLink),
       mediatorDid = Value(mediatorDid),
       type = Value(type),
       status = Value(status),
       origin = Value(origin),
       category = Value(category);
  static Insertable<Contact> custom({
    Expression<String>? id,
    Expression<String>? channelDid,
    Expression<String>? channelDidSha256,
    Expression<DateTime>? dateAdded,
    Expression<String>? offerLink,
    Expression<String>? mediatorDid,
    Expression<int>? type,
    Expression<int>? status,
    Expression<int>? origin,
    Expression<int>? category,
    Expression<String>? displayName,
    Expression<bool>? badgeUpdateInProgress,
    Expression<int>? badgeCount,
    Expression<int>? currentMessageSeqNo,
    Expression<int>? missedCallCount,
    Expression<DateTime>? pendingMissedCallAt,
    Expression<String>? pendingMissedCallId,
    Expression<String>? activeIncomingCallId,
    Expression<bool>? hasBeenOpened,
    Expression<DateTime>? lastKeepAliveMessage,
    Expression<bool>? notificationBannerDismissed,
    Expression<String>? personalAgentAuthorizationSnapshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelDid != null) 'channel_did': channelDid,
      if (channelDidSha256 != null) 'channel_did_sha256': channelDidSha256,
      if (dateAdded != null) 'date_added': dateAdded,
      if (offerLink != null) 'offer_link': offerLink,
      if (mediatorDid != null) 'mediator_did': mediatorDid,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (category != null) 'category': category,
      if (displayName != null) 'display_name': displayName,
      if (badgeUpdateInProgress != null)
        'badge_update_in_progress': badgeUpdateInProgress,
      if (badgeCount != null) 'badge_count': badgeCount,
      if (currentMessageSeqNo != null)
        'current_message_seq_no': currentMessageSeqNo,
      if (missedCallCount != null) 'missed_call_count': missedCallCount,
      if (pendingMissedCallAt != null)
        'pending_missed_call_at': pendingMissedCallAt,
      if (pendingMissedCallId != null)
        'pending_missed_call_id': pendingMissedCallId,
      if (activeIncomingCallId != null)
        'active_incoming_call_id': activeIncomingCallId,
      if (hasBeenOpened != null) 'has_been_opened': hasBeenOpened,
      if (lastKeepAliveMessage != null)
        'last_keep_alive_message': lastKeepAliveMessage,
      if (notificationBannerDismissed != null)
        'notification_banner_dismissed': notificationBannerDismissed,
      if (personalAgentAuthorizationSnapshot != null)
        'personal_agent_authorization_snapshot':
            personalAgentAuthorizationSnapshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? id,
    Value<String?>? channelDid,
    Value<String?>? channelDidSha256,
    Value<DateTime>? dateAdded,
    Value<String>? offerLink,
    Value<String>? mediatorDid,
    Value<ContactType>? type,
    Value<ContactStatus>? status,
    Value<ContactOrigin>? origin,
    Value<ContactCategory>? category,
    Value<String?>? displayName,
    Value<bool>? badgeUpdateInProgress,
    Value<int>? badgeCount,
    Value<int>? currentMessageSeqNo,
    Value<int>? missedCallCount,
    Value<DateTime?>? pendingMissedCallAt,
    Value<String?>? pendingMissedCallId,
    Value<String?>? activeIncomingCallId,
    Value<bool>? hasBeenOpened,
    Value<DateTime?>? lastKeepAliveMessage,
    Value<bool>? notificationBannerDismissed,
    Value<String?>? personalAgentAuthorizationSnapshot,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      channelDid: channelDid ?? this.channelDid,
      channelDidSha256: channelDidSha256 ?? this.channelDidSha256,
      dateAdded: dateAdded ?? this.dateAdded,
      offerLink: offerLink ?? this.offerLink,
      mediatorDid: mediatorDid ?? this.mediatorDid,
      type: type ?? this.type,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      category: category ?? this.category,
      displayName: displayName ?? this.displayName,
      badgeUpdateInProgress:
          badgeUpdateInProgress ?? this.badgeUpdateInProgress,
      badgeCount: badgeCount ?? this.badgeCount,
      currentMessageSeqNo: currentMessageSeqNo ?? this.currentMessageSeqNo,
      missedCallCount: missedCallCount ?? this.missedCallCount,
      pendingMissedCallAt: pendingMissedCallAt ?? this.pendingMissedCallAt,
      pendingMissedCallId: pendingMissedCallId ?? this.pendingMissedCallId,
      activeIncomingCallId: activeIncomingCallId ?? this.activeIncomingCallId,
      hasBeenOpened: hasBeenOpened ?? this.hasBeenOpened,
      lastKeepAliveMessage: lastKeepAliveMessage ?? this.lastKeepAliveMessage,
      notificationBannerDismissed:
          notificationBannerDismissed ?? this.notificationBannerDismissed,
      personalAgentAuthorizationSnapshot:
          personalAgentAuthorizationSnapshot ??
          this.personalAgentAuthorizationSnapshot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (channelDid.present) {
      map['channel_did'] = Variable<String>(channelDid.value);
    }
    if (channelDidSha256.present) {
      map['channel_did_sha256'] = Variable<String>(channelDidSha256.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (offerLink.present) {
      map['offer_link'] = Variable<String>(offerLink.value);
    }
    if (mediatorDid.present) {
      map['mediator_did'] = Variable<String>(mediatorDid.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $ContactsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $ContactsTable.$converterstatus.toSql(status.value),
      );
    }
    if (origin.present) {
      map['origin'] = Variable<int>(
        $ContactsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $ContactsTable.$convertercategory.toSql(category.value),
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (badgeUpdateInProgress.present) {
      map['badge_update_in_progress'] = Variable<bool>(
        badgeUpdateInProgress.value,
      );
    }
    if (badgeCount.present) {
      map['badge_count'] = Variable<int>(badgeCount.value);
    }
    if (currentMessageSeqNo.present) {
      map['current_message_seq_no'] = Variable<int>(currentMessageSeqNo.value);
    }
    if (missedCallCount.present) {
      map['missed_call_count'] = Variable<int>(missedCallCount.value);
    }
    if (pendingMissedCallAt.present) {
      map['pending_missed_call_at'] = Variable<DateTime>(
        pendingMissedCallAt.value,
      );
    }
    if (pendingMissedCallId.present) {
      map['pending_missed_call_id'] = Variable<String>(
        pendingMissedCallId.value,
      );
    }
    if (activeIncomingCallId.present) {
      map['active_incoming_call_id'] = Variable<String>(
        activeIncomingCallId.value,
      );
    }
    if (hasBeenOpened.present) {
      map['has_been_opened'] = Variable<bool>(hasBeenOpened.value);
    }
    if (lastKeepAliveMessage.present) {
      map['last_keep_alive_message'] = Variable<DateTime>(
        lastKeepAliveMessage.value,
      );
    }
    if (notificationBannerDismissed.present) {
      map['notification_banner_dismissed'] = Variable<bool>(
        notificationBannerDismissed.value,
      );
    }
    if (personalAgentAuthorizationSnapshot.present) {
      map['personal_agent_authorization_snapshot'] = Variable<String>(
        personalAgentAuthorizationSnapshot.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('channelDid: $channelDid, ')
          ..write('channelDidSha256: $channelDidSha256, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('offerLink: $offerLink, ')
          ..write('mediatorDid: $mediatorDid, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('category: $category, ')
          ..write('displayName: $displayName, ')
          ..write('badgeUpdateInProgress: $badgeUpdateInProgress, ')
          ..write('badgeCount: $badgeCount, ')
          ..write('currentMessageSeqNo: $currentMessageSeqNo, ')
          ..write('missedCallCount: $missedCallCount, ')
          ..write('pendingMissedCallAt: $pendingMissedCallAt, ')
          ..write('pendingMissedCallId: $pendingMissedCallId, ')
          ..write('activeIncomingCallId: $activeIncomingCallId, ')
          ..write('hasBeenOpened: $hasBeenOpened, ')
          ..write('lastKeepAliveMessage: $lastKeepAliveMessage, ')
          ..write('notificationBannerDismissed: $notificationBannerDismissed, ')
          ..write(
            'personalAgentAuthorizationSnapshot: $personalAgentAuthorizationSnapshot, ',
          )
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactCardsTable extends ContactCards
    with TableInfo<$ContactCardsTable, ContactCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'REFERENCES contacts(id) ON DELETE CASCADE UNIQUE NOT NULL',
  );
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<String> did = GeneratedColumn<String>(
    'did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactInfoJsonMeta = const VerificationMeta(
    'contactInfoJson',
  );
  @override
  late final GeneratedColumn<String> contactInfoJson = GeneratedColumn<String>(
    'contact_info_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _profilePicMeta = const VerificationMeta(
    'profilePic',
  );
  @override
  late final GeneratedColumn<String> profilePic = GeneratedColumn<String>(
    'profile_pic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    did,
    type,
    contactInfoJson,
    profilePic,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('did')) {
      context.handle(
        _didMeta,
        did.isAcceptableOrUnknown(data['did']!, _didMeta),
      );
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('contact_info_json')) {
      context.handle(
        _contactInfoJsonMeta,
        contactInfoJson.isAcceptableOrUnknown(
          data['contact_info_json']!,
          _contactInfoJsonMeta,
        ),
      );
    }
    if (data.containsKey('profile_pic')) {
      context.handle(
        _profilePicMeta,
        profilePic.isAcceptableOrUnknown(data['profile_pic']!, _profilePicMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      did: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}did'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      contactInfoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_info_json'],
      )!,
      profilePic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_pic'],
      ),
    );
  }

  @override
  $ContactCardsTable createAlias(String alias) {
    return $ContactCardsTable(attachedDatabase, alias);
  }
}

class ContactCard extends DataClass implements Insertable<ContactCard> {
  final int id;
  final String contactId;
  final String did;
  final String type;
  final String contactInfoJson;
  final String? profilePic;
  const ContactCard({
    required this.id,
    required this.contactId,
    required this.did,
    required this.type,
    required this.contactInfoJson,
    this.profilePic,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['did'] = Variable<String>(did);
    map['type'] = Variable<String>(type);
    map['contact_info_json'] = Variable<String>(contactInfoJson);
    if (!nullToAbsent || profilePic != null) {
      map['profile_pic'] = Variable<String>(profilePic);
    }
    return map;
  }

  ContactCardsCompanion toCompanion(bool nullToAbsent) {
    return ContactCardsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      did: Value(did),
      type: Value(type),
      contactInfoJson: Value(contactInfoJson),
      profilePic: profilePic == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePic),
    );
  }

  factory ContactCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactCard(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      did: serializer.fromJson<String>(json['did']),
      type: serializer.fromJson<String>(json['type']),
      contactInfoJson: serializer.fromJson<String>(json['contactInfoJson']),
      profilePic: serializer.fromJson<String?>(json['profilePic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<String>(contactId),
      'did': serializer.toJson<String>(did),
      'type': serializer.toJson<String>(type),
      'contactInfoJson': serializer.toJson<String>(contactInfoJson),
      'profilePic': serializer.toJson<String?>(profilePic),
    };
  }

  ContactCard copyWith({
    int? id,
    String? contactId,
    String? did,
    String? type,
    String? contactInfoJson,
    Value<String?> profilePic = const Value.absent(),
  }) => ContactCard(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    did: did ?? this.did,
    type: type ?? this.type,
    contactInfoJson: contactInfoJson ?? this.contactInfoJson,
    profilePic: profilePic.present ? profilePic.value : this.profilePic,
  );
  ContactCard copyWithCompanion(ContactCardsCompanion data) {
    return ContactCard(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      did: data.did.present ? data.did.value : this.did,
      type: data.type.present ? data.type.value : this.type,
      contactInfoJson: data.contactInfoJson.present
          ? data.contactInfoJson.value
          : this.contactInfoJson,
      profilePic: data.profilePic.present
          ? data.profilePic.value
          : this.profilePic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactCard(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('did: $did, ')
          ..write('type: $type, ')
          ..write('contactInfoJson: $contactInfoJson, ')
          ..write('profilePic: $profilePic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactId, did, type, contactInfoJson, profilePic);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactCard &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.did == this.did &&
          other.type == this.type &&
          other.contactInfoJson == this.contactInfoJson &&
          other.profilePic == this.profilePic);
}

class ContactCardsCompanion extends UpdateCompanion<ContactCard> {
  final Value<int> id;
  final Value<String> contactId;
  final Value<String> did;
  final Value<String> type;
  final Value<String> contactInfoJson;
  final Value<String?> profilePic;
  const ContactCardsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.did = const Value.absent(),
    this.type = const Value.absent(),
    this.contactInfoJson = const Value.absent(),
    this.profilePic = const Value.absent(),
  });
  ContactCardsCompanion.insert({
    this.id = const Value.absent(),
    required String contactId,
    required String did,
    required String type,
    this.contactInfoJson = const Value.absent(),
    this.profilePic = const Value.absent(),
  }) : contactId = Value(contactId),
       did = Value(did),
       type = Value(type);
  static Insertable<ContactCard> custom({
    Expression<int>? id,
    Expression<String>? contactId,
    Expression<String>? did,
    Expression<String>? type,
    Expression<String>? contactInfoJson,
    Expression<String>? profilePic,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (did != null) 'did': did,
      if (type != null) 'type': type,
      if (contactInfoJson != null) 'contact_info_json': contactInfoJson,
      if (profilePic != null) 'profile_pic': profilePic,
    });
  }

  ContactCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? contactId,
    Value<String>? did,
    Value<String>? type,
    Value<String>? contactInfoJson,
    Value<String?>? profilePic,
  }) {
    return ContactCardsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      did: did ?? this.did,
      type: type ?? this.type,
      contactInfoJson: contactInfoJson ?? this.contactInfoJson,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (did.present) {
      map['did'] = Variable<String>(did.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (contactInfoJson.present) {
      map['contact_info_json'] = Variable<String>(contactInfoJson.value);
    }
    if (profilePic.present) {
      map['profile_pic'] = Variable<String>(profilePic.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactCardsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('did: $did, ')
          ..write('type: $type, ')
          ..write('contactInfoJson: $contactInfoJson, ')
          ..write('profilePic: $profilePic')
          ..write(')'))
        .toString();
  }
}

abstract class _$ContactsDatabase extends GeneratedDatabase {
  _$ContactsDatabase(QueryExecutor e) : super(e);
  $ContactsDatabaseManager get managers => $ContactsDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ContactCardsTable contactCards = $ContactCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [contacts, contactCards];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_cards', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> id,
      Value<String?> channelDid,
      Value<String?> channelDidSha256,
      Value<DateTime> dateAdded,
      required String offerLink,
      required String mediatorDid,
      required ContactType type,
      required ContactStatus status,
      required ContactOrigin origin,
      required ContactCategory category,
      Value<String?> displayName,
      Value<bool> badgeUpdateInProgress,
      Value<int> badgeCount,
      Value<int> currentMessageSeqNo,
      Value<int> missedCallCount,
      Value<DateTime?> pendingMissedCallAt,
      Value<String?> pendingMissedCallId,
      Value<String?> activeIncomingCallId,
      Value<bool> hasBeenOpened,
      Value<DateTime?> lastKeepAliveMessage,
      Value<bool> notificationBannerDismissed,
      Value<String?> personalAgentAuthorizationSnapshot,
      Value<int> rowid,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> id,
      Value<String?> channelDid,
      Value<String?> channelDidSha256,
      Value<DateTime> dateAdded,
      Value<String> offerLink,
      Value<String> mediatorDid,
      Value<ContactType> type,
      Value<ContactStatus> status,
      Value<ContactOrigin> origin,
      Value<ContactCategory> category,
      Value<String?> displayName,
      Value<bool> badgeUpdateInProgress,
      Value<int> badgeCount,
      Value<int> currentMessageSeqNo,
      Value<int> missedCallCount,
      Value<DateTime?> pendingMissedCallAt,
      Value<String?> pendingMissedCallId,
      Value<String?> activeIncomingCallId,
      Value<bool> hasBeenOpened,
      Value<DateTime?> lastKeepAliveMessage,
      Value<bool> notificationBannerDismissed,
      Value<String?> personalAgentAuthorizationSnapshot,
      Value<int> rowid,
    });

final class $$ContactsTableReferences
    extends BaseReferences<_$ContactsDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContactCardsTable, List<ContactCard>>
  _contactCardsRefsTable(_$ContactsDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactCards,
        aliasName: $_aliasNameGenerator(
          db.contacts.id,
          db.contactCards.contactId,
        ),
      );

  $$ContactCardsTableProcessedTableManager get contactCardsRefs {
    final manager = $$ContactCardsTableTableManager(
      $_db,
      $_db.contactCards,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$ContactsDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelDid => $composableBuilder(
    column: $table.channelDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelDidSha256 => $composableBuilder(
    column: $table.channelDidSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offerLink => $composableBuilder(
    column: $table.offerLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediatorDid => $composableBuilder(
    column: $table.mediatorDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ContactType, ContactType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ContactStatus, ContactStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ContactOrigin, ContactOrigin, int>
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ContactCategory, ContactCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get badgeUpdateInProgress => $composableBuilder(
    column: $table.badgeUpdateInProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get badgeCount => $composableBuilder(
    column: $table.badgeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentMessageSeqNo => $composableBuilder(
    column: $table.currentMessageSeqNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get missedCallCount => $composableBuilder(
    column: $table.missedCallCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pendingMissedCallAt => $composableBuilder(
    column: $table.pendingMissedCallAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingMissedCallId => $composableBuilder(
    column: $table.pendingMissedCallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeIncomingCallId => $composableBuilder(
    column: $table.activeIncomingCallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasBeenOpened => $composableBuilder(
    column: $table.hasBeenOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastKeepAliveMessage => $composableBuilder(
    column: $table.lastKeepAliveMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationBannerDismissed => $composableBuilder(
    column: $table.notificationBannerDismissed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalAgentAuthorizationSnapshot =>
      $composableBuilder(
        column: $table.personalAgentAuthorizationSnapshot,
        builder: (column) => ColumnFilters(column),
      );

  Expression<bool> contactCardsRefs(
    Expression<bool> Function($$ContactCardsTableFilterComposer f) f,
  ) {
    final $$ContactCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactCards,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactCardsTableFilterComposer(
            $db: $db,
            $table: $db.contactCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$ContactsDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelDid => $composableBuilder(
    column: $table.channelDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelDidSha256 => $composableBuilder(
    column: $table.channelDidSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offerLink => $composableBuilder(
    column: $table.offerLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediatorDid => $composableBuilder(
    column: $table.mediatorDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get badgeUpdateInProgress => $composableBuilder(
    column: $table.badgeUpdateInProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get badgeCount => $composableBuilder(
    column: $table.badgeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentMessageSeqNo => $composableBuilder(
    column: $table.currentMessageSeqNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get missedCallCount => $composableBuilder(
    column: $table.missedCallCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pendingMissedCallAt => $composableBuilder(
    column: $table.pendingMissedCallAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingMissedCallId => $composableBuilder(
    column: $table.pendingMissedCallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeIncomingCallId => $composableBuilder(
    column: $table.activeIncomingCallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasBeenOpened => $composableBuilder(
    column: $table.hasBeenOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastKeepAliveMessage => $composableBuilder(
    column: $table.lastKeepAliveMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationBannerDismissed => $composableBuilder(
    column: $table.notificationBannerDismissed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalAgentAuthorizationSnapshot =>
      $composableBuilder(
        column: $table.personalAgentAuthorizationSnapshot,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$ContactsDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get channelDid => $composableBuilder(
    column: $table.channelDid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelDidSha256 => $composableBuilder(
    column: $table.channelDidSha256,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<String> get offerLink =>
      $composableBuilder(column: $table.offerLink, builder: (column) => column);

  GeneratedColumn<String> get mediatorDid => $composableBuilder(
    column: $table.mediatorDid,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ContactType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactOrigin, int> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get badgeUpdateInProgress => $composableBuilder(
    column: $table.badgeUpdateInProgress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get badgeCount => $composableBuilder(
    column: $table.badgeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentMessageSeqNo => $composableBuilder(
    column: $table.currentMessageSeqNo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get missedCallCount => $composableBuilder(
    column: $table.missedCallCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pendingMissedCallAt => $composableBuilder(
    column: $table.pendingMissedCallAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingMissedCallId => $composableBuilder(
    column: $table.pendingMissedCallId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeIncomingCallId => $composableBuilder(
    column: $table.activeIncomingCallId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasBeenOpened => $composableBuilder(
    column: $table.hasBeenOpened,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastKeepAliveMessage => $composableBuilder(
    column: $table.lastKeepAliveMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationBannerDismissed => $composableBuilder(
    column: $table.notificationBannerDismissed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalAgentAuthorizationSnapshot =>
      $composableBuilder(
        column: $table.personalAgentAuthorizationSnapshot,
        builder: (column) => column,
      );

  Expression<T> contactCardsRefs<T extends Object>(
    Expression<T> Function($$ContactCardsTableAnnotationComposer a) f,
  ) {
    final $$ContactCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactCards,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$ContactsDatabase,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, $$ContactsTableReferences),
          Contact,
          PrefetchHooks Function({bool contactCardsRefs})
        > {
  $$ContactsTableTableManager(_$ContactsDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> channelDid = const Value.absent(),
                Value<String?> channelDidSha256 = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<String> offerLink = const Value.absent(),
                Value<String> mediatorDid = const Value.absent(),
                Value<ContactType> type = const Value.absent(),
                Value<ContactStatus> status = const Value.absent(),
                Value<ContactOrigin> origin = const Value.absent(),
                Value<ContactCategory> category = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> badgeUpdateInProgress = const Value.absent(),
                Value<int> badgeCount = const Value.absent(),
                Value<int> currentMessageSeqNo = const Value.absent(),
                Value<int> missedCallCount = const Value.absent(),
                Value<DateTime?> pendingMissedCallAt = const Value.absent(),
                Value<String?> pendingMissedCallId = const Value.absent(),
                Value<String?> activeIncomingCallId = const Value.absent(),
                Value<bool> hasBeenOpened = const Value.absent(),
                Value<DateTime?> lastKeepAliveMessage = const Value.absent(),
                Value<bool> notificationBannerDismissed = const Value.absent(),
                Value<String?> personalAgentAuthorizationSnapshot =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                channelDid: channelDid,
                channelDidSha256: channelDidSha256,
                dateAdded: dateAdded,
                offerLink: offerLink,
                mediatorDid: mediatorDid,
                type: type,
                status: status,
                origin: origin,
                category: category,
                displayName: displayName,
                badgeUpdateInProgress: badgeUpdateInProgress,
                badgeCount: badgeCount,
                currentMessageSeqNo: currentMessageSeqNo,
                missedCallCount: missedCallCount,
                pendingMissedCallAt: pendingMissedCallAt,
                pendingMissedCallId: pendingMissedCallId,
                activeIncomingCallId: activeIncomingCallId,
                hasBeenOpened: hasBeenOpened,
                lastKeepAliveMessage: lastKeepAliveMessage,
                notificationBannerDismissed: notificationBannerDismissed,
                personalAgentAuthorizationSnapshot:
                    personalAgentAuthorizationSnapshot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> channelDid = const Value.absent(),
                Value<String?> channelDidSha256 = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                required String offerLink,
                required String mediatorDid,
                required ContactType type,
                required ContactStatus status,
                required ContactOrigin origin,
                required ContactCategory category,
                Value<String?> displayName = const Value.absent(),
                Value<bool> badgeUpdateInProgress = const Value.absent(),
                Value<int> badgeCount = const Value.absent(),
                Value<int> currentMessageSeqNo = const Value.absent(),
                Value<int> missedCallCount = const Value.absent(),
                Value<DateTime?> pendingMissedCallAt = const Value.absent(),
                Value<String?> pendingMissedCallId = const Value.absent(),
                Value<String?> activeIncomingCallId = const Value.absent(),
                Value<bool> hasBeenOpened = const Value.absent(),
                Value<DateTime?> lastKeepAliveMessage = const Value.absent(),
                Value<bool> notificationBannerDismissed = const Value.absent(),
                Value<String?> personalAgentAuthorizationSnapshot =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                channelDid: channelDid,
                channelDidSha256: channelDidSha256,
                dateAdded: dateAdded,
                offerLink: offerLink,
                mediatorDid: mediatorDid,
                type: type,
                status: status,
                origin: origin,
                category: category,
                displayName: displayName,
                badgeUpdateInProgress: badgeUpdateInProgress,
                badgeCount: badgeCount,
                currentMessageSeqNo: currentMessageSeqNo,
                missedCallCount: missedCallCount,
                pendingMissedCallAt: pendingMissedCallAt,
                pendingMissedCallId: pendingMissedCallId,
                activeIncomingCallId: activeIncomingCallId,
                hasBeenOpened: hasBeenOpened,
                lastKeepAliveMessage: lastKeepAliveMessage,
                notificationBannerDismissed: notificationBannerDismissed,
                personalAgentAuthorizationSnapshot:
                    personalAgentAuthorizationSnapshot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (contactCardsRefs) db.contactCards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contactCardsRefs)
                    await $_getPrefetchedData<
                      Contact,
                      $ContactsTable,
                      ContactCard
                    >(
                      currentTable: table,
                      referencedTable: $$ContactsTableReferences
                          ._contactCardsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ContactsTableReferences(
                        db,
                        table,
                        p0,
                      ).contactCardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contactId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$ContactsDatabase,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, $$ContactsTableReferences),
      Contact,
      PrefetchHooks Function({bool contactCardsRefs})
    >;
typedef $$ContactCardsTableCreateCompanionBuilder =
    ContactCardsCompanion Function({
      Value<int> id,
      required String contactId,
      required String did,
      required String type,
      Value<String> contactInfoJson,
      Value<String?> profilePic,
    });
typedef $$ContactCardsTableUpdateCompanionBuilder =
    ContactCardsCompanion Function({
      Value<int> id,
      Value<String> contactId,
      Value<String> did,
      Value<String> type,
      Value<String> contactInfoJson,
      Value<String?> profilePic,
    });

final class $$ContactCardsTableReferences
    extends
        BaseReferences<_$ContactsDatabase, $ContactCardsTable, ContactCard> {
  $$ContactCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$ContactsDatabase db) =>
      db.contacts.createAlias(
        $_aliasNameGenerator(db.contactCards.contactId, db.contacts.id),
      );

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactCardsTableFilterComposer
    extends Composer<_$ContactsDatabase, $ContactCardsTable> {
  $$ContactCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactInfoJson => $composableBuilder(
    column: $table.contactInfoJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePic => $composableBuilder(
    column: $table.profilePic,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactCardsTableOrderingComposer
    extends Composer<_$ContactsDatabase, $ContactCardsTable> {
  $$ContactCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactInfoJson => $composableBuilder(
    column: $table.contactInfoJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePic => $composableBuilder(
    column: $table.profilePic,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactCardsTableAnnotationComposer
    extends Composer<_$ContactsDatabase, $ContactCardsTable> {
  $$ContactCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contactInfoJson => $composableBuilder(
    column: $table.contactInfoJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profilePic => $composableBuilder(
    column: $table.profilePic,
    builder: (column) => column,
  );

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactCardsTableTableManager
    extends
        RootTableManager<
          _$ContactsDatabase,
          $ContactCardsTable,
          ContactCard,
          $$ContactCardsTableFilterComposer,
          $$ContactCardsTableOrderingComposer,
          $$ContactCardsTableAnnotationComposer,
          $$ContactCardsTableCreateCompanionBuilder,
          $$ContactCardsTableUpdateCompanionBuilder,
          (ContactCard, $$ContactCardsTableReferences),
          ContactCard,
          PrefetchHooks Function({bool contactId})
        > {
  $$ContactCardsTableTableManager(
    _$ContactsDatabase db,
    $ContactCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<String> did = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> contactInfoJson = const Value.absent(),
                Value<String?> profilePic = const Value.absent(),
              }) => ContactCardsCompanion(
                id: id,
                contactId: contactId,
                did: did,
                type: type,
                contactInfoJson: contactInfoJson,
                profilePic: profilePic,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contactId,
                required String did,
                required String type,
                Value<String> contactInfoJson = const Value.absent(),
                Value<String?> profilePic = const Value.absent(),
              }) => ContactCardsCompanion.insert(
                id: id,
                contactId: contactId,
                did: did,
                type: type,
                contactInfoJson: contactInfoJson,
                profilePic: profilePic,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable: $$ContactCardsTableReferences
                                    ._contactIdTable(db),
                                referencedColumn: $$ContactCardsTableReferences
                                    ._contactIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ContactCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$ContactsDatabase,
      $ContactCardsTable,
      ContactCard,
      $$ContactCardsTableFilterComposer,
      $$ContactCardsTableOrderingComposer,
      $$ContactCardsTableAnnotationComposer,
      $$ContactCardsTableCreateCompanionBuilder,
      $$ContactCardsTableUpdateCompanionBuilder,
      (ContactCard, $$ContactCardsTableReferences),
      ContactCard,
      PrefetchHooks Function({bool contactId})
    >;

class $ContactsDatabaseManager {
  final _$ContactsDatabase _db;
  $ContactsDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$ContactCardsTableTableManager get contactCards =>
      $$ContactCardsTableTableManager(_db, _db.contactCards);
}
