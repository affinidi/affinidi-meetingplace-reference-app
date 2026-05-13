# Adding a New Profile Field

Profile fields (first name, last name, email, mobile, …) are driven by a
single registry: `ContactCardFieldDefinitions.values` in
`app/lib/domain/models/contact_card/contact_card_field_definition.dart`.

Append a new entry there and the field automatically appears in:

- The identity form (create / edit profile)
- The contact card view widget
- The identity picker card
- The connection details screens
- Full-text search (if tagged `searchable`)

No database migration is needed — all field values are stored as JSON inside
the existing `contact_info_json` column.

---

## Steps

### 1. Add a key to `ContactCardFieldKey`

Open `contact_card_field_definition.dart` and add a new value to the enum:

```dart
enum ContactCardFieldKey { firstName, lastName, email, mobile, website }
//                                                              ^^^^^^^
```

### 2. Add the field to `ContactCard`

Open `app/lib/domain/models/contact_card/contact_card.dart` and add a
nullable property to the freezed class:

```dart
@freezed
abstract class ContactCard with _$ContactCard {
  const factory ContactCard({
    // … existing fields …
    String? website,   // <-- add this
  }) = _ContactCard;
```

Also add it to `ContactCard.empty()` with a `null` default.

### 3. Append a `ContactCardFieldDefinition`

Back in `contact_card_field_definition.dart`, append a new entry to the
`ContactCardFieldDefinitions.values` list:

```dart
ContactCardFieldDefinition(
  key: ContactCardFieldKey.website,
  icon: Icons.language,
  iconColor: (customColors, colorScheme) => Colors.teal,
  keyboardType: TextInputType.url,
  textCapitalization: TextCapitalization.none,
  autocorrect: false,
  shouldValidateOnBlur: true,
  textInputAction: TextInputAction.next,
  placeholder: (l10n) => l10n.enterWebsite,  // add to .arb files (step 4b)
  validators: (context) => [
    // add validators as needed
  ],
  // JSON path inside contactInfoJson — follow jCard conventions.
  jsonPath: const ['url', 'type', 'work'],
  nullWhenEmpty: true,
  valueAccessor: (card) => card.website,
  updateCard: (card, value) => card.copyWith(website: value),
  tags: const [ContactCardFieldTags.searchable], // optional
),
```

**`jsonPath`** determines the key path used when serialising / deserialising
the value from the JSON blob. Follow the
[jCard (RFC 7095)](https://datatracker.ietf.org/doc/html/rfc7095) property
naming conventions where possible (e.g. `url`, `tel`, `email`, `n`).

**`tags`** controls extra behaviour:

| Tag | Effect |
|---|---|
| `ContactCardFieldTags.searchable` | Value is included in contact / identity full-text search |
| `ContactCardFieldTags.identityCard` | Value is shown on the compact identity card chip |

### 4. Add localisations

#### a. Label (`contactCardFieldName`)

Add the new key to the `select` clause in every `.arb` file under
`app/lib/l10n/`:

```
// app_en.arb
"contactCardFieldName": "{field, select, firstName{First name} lastName{Last name} email{Email} mobile{Mobile} website{Website} other{}}",

// app_de.arb
"contactCardFieldName": "{field, select, firstName{Vorname} lastName{Nachname} email{E-Mail} mobile{Mobil} website{Website} other{}}",

// app_es.arb
"contactCardFieldName": "{field, select, firstName{Nombre} lastName{Apellido} email{Correo electrónico} mobile{Móvil} website{Sitio web} other{}}",
```

#### b. Placeholder string

Add a new string entry (used by `placeholder` in step 3) to each `.arb` file:

```json
"enterWebsite": "Enter website",
```

### 5. Regenerate code

```bash
melos gen
```

This regenerates the freezed `ContactCard` class and the localisation
delegates.

---
