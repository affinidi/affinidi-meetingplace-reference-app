const aliceSmithVcBlob =
    '{"type":["VerifiableCredential","RelationshipCard"],'
    '"issuer":"did:key:issuer","validFrom":"2024-01-01T00:00:00Z",'
    '"credentialSubject":{"id":"did:key:alice",'
    '"card":["vcard",[["firstName",{},"text","Alice"],'
    '["lastName",{},"text","Smith"]]]}}';

const bobJonesVcBlob =
    '{"type":["VerifiableCredential","RelationshipCard"],'
    '"issuer":"did:key:issuer","validFrom":"2024-01-01T00:00:00Z",'
    '"credentialSubject":{"id":"did:key:bob",'
    '"card":["vcard",[["firstName",{},"text","Bob"],'
    '["lastName",{},"text","Jones"]]]}}';

const anonymousVcBlob =
    '{"type":["VerifiableCredential","RelationshipCard"],'
    '"issuer":"did:key:issuer","validFrom":"2024-01-01T00:00:00Z",'
    '"credentialSubject":{"id":"did:key:anon",'
    '"card":["vcard",[["firstName",{},"text","Anonymous"]]]}}';
