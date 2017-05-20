<SPConfig xmlns="urn:mace:shibboleth:2.0:native:sp:config"
          xmlns:conf="urn:mace:shibboleth:2.0:native:sp:config"
          xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
          xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
          xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
          clockSkew="180">

    <!--
    By default, in-memory StorageService, ReplayCache, ArtifactMap, and SessionCache
    are used. See example-shibboleth2.xml for samples of explicitly configuring them.
    -->

    <!--
    To customize behavior for specific resources on Apache, and to link vhosts or
    resources to ApplicationOverride settings below, use web server options/commands.
    See https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPConfigurationElements for help.

    For examples with the RequestMap XML syntax instead, see the example-shibboleth2.xml
    file, and the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapHowTo topic.
    -->
    <!-- To customize behavior, map hostnames and path components to applicationId and other settings. -->
    <RequestMapper type="XML">
        <RequestMap applicationId="client"
                    authType="shibboleth">
            <Host name="${CLIENT_APP_HOSTNAME:-your-app.localdomain.com}"
                  requireSession="true">
                <Path name="${CLIENT_APP_SECURE_PATH:-/app}" />
            </Host>
        </RequestMap>
    </RequestMapper>

    <!-- The ApplicationDefaults element is where most of Shibboleth's SAML bits are defined. -->
    <ApplicationDefaults entityID="http://FAKE-DOMAIN/NOT-USED"
                         REMOTE_USER="eppn persistent-id targeted-id">
        <!--
        Controls session lifetimes, address checks, cookie handling, and the protocol handlers.
        You MUST supply an effectively unique handlerURL value for each of your applications.
        The value defaults to /Shibboleth.sso, and should be a relative path, with the SP computing
        a relative value based on the virtual host. Using handlerSSL="true", the default, will force
        the protocol to be https. You should also set cookieProps to "https" for SSL-only sites.
        Note that while we default checkAddress to "false", this has a negative impact on the
        security of your site. Stealing sessions via cookie theft is much easier with this disabled.
        -->
        <Sessions lifetime="28800" timeout="3600" relayState="ss:mem"
                  handlerSSL="false"
                  checkAddress="false"
                  cookieProps="http">

            <!--
            Configures SSO for a default IdP. To allow for >1 IdP, remove
            entityID property and adjust discoveryURL to point to discovery service.
            (Set discoveryProtocol to "WAYF" for legacy Shibboleth WAYF support.)
            You can also override entityID on /Login query string, or in RequestMap/htaccess.
            -->
            <SSO entityID="https://shibboleth-test.usc.edu/shibboleth-idp">SAML2 SAML1</SSO>

            <!-- SAML and local-only logout. -->
            <Logout>SAML2 Local</Logout>

            <!-- Extension service that generates "approximate" metadata based on SP configuration. -->
            <Handler type="MetadataGenerator" Location="/metadata" signing="false"/>

            <!-- Status reporting service. -->
            <Handler type="Status" Location="/status" />

            <!-- Session diagnostic service. -->
            <Handler type="Session" Location="/session" showAttributeValues="true"/>

            <!-- JSON feed of discovery information. -->
            <Handler type="DiscoveryFeed" Location="/discoFeed"/>
        </Sessions>

        <!--
        Allows overriding of error template information/filenames. You can
        also add attributes with values that can be plugged into the templates.
        -->
        <Errors supportContact="iskandar@hellomatter.com"
                helpLocation="/about.html"
                styleSheet="/shibboleth-sp/main.css"/>

        <!--
          - TestShib
          - @see http://www.testshib.org/
          -->
        <MetadataProvider type="XML"
                          uri="https://shibboleth.usc.edu/USC-metadata.xml"
                          backingFilePath="USC-metadata.xml"
                          reloadInterval="86400" />

        <!-- Map to extract attributes from SAML assertions. -->
        <AttributeExtractor type="XML" validate="true" reloadChanges="false" path="attribute-map.xml"/>

        <!-- Use a SAML query if no attributes are supplied during SSO. -->
        <AttributeResolver type="Query" subjectMatch="true"/>

        <!-- Default filtering policy for recognized attributes, lets other data pass. -->
        <AttributeFilter type="XML" validate="true" path="attribute-policy.xml"/>

        <!-- Simple file-based resolver for using a single keypair. -->
        <CredentialResolver type="File"
                            key="/run/secrets/sp-key.pem"
                            certificate="/run/secrets/sp-cert.pem"/>

        <!--
        The default settings can be overridden by creating ApplicationOverride elements (see
        the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApplicationOverride topic).
        Resource requests are mapped by web server commands, or the RequestMapper, to an
        applicationId setting.

        Example of a second application (for a second vhost) that has a different entityID.
        Resources on the vhost would map to an applicationId of "admin":
        -->
        <!--
        <ApplicationOverride id="admin" entityID="https://admin.example.org/shibboleth"/>
        -->

        <ApplicationOverride id="client" entityID="${CLIENT_APP_SCHEME:-https}://${CLIENT_APP_HOSTNAME:-your-app.localdomain.com}${SHIBBOLETH_RESPONDER_PATH:-/saml}/metadata">
            <Sessions lifetime="28800" timeout="3600" relayState="ss:mem"
                      handlerURL="${SHIBBOLETH_RESPONDER_PATH:-/saml}"
                      handlerSSL="false"
                      checkAddress="false"
                      cookieProps="http">

                <!-- DEFAULT to OpenIdP -->
                <SSO entityID="https://shibboleth-test.usc.edu/shibboleth-idp">
                    SAML2 SAML1
                </SSO>

                <!-- Extension service that generates "approximate" metadata based on SP configuration. -->
                <Handler type="MetadataGenerator" Location="/metadata" signing="false"/>

                <!-- Status reporting service. -->
                <Handler type="Status" Location="/status" />

                <!-- Session diagnostic service. -->
                <Handler type="Session" Location="/session" showAttributeValues="true"/>

                <!-- Change the ACS URL -->
                <md:AssertionConsumerService Location="/acs"
                                             index="1" isDefault="true"
                                             Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" />

            </Sessions>
        </ApplicationOverride>

    </ApplicationDefaults>

    <!-- Policies that determine how to process and authenticate runtime messages. -->
    <SecurityPolicyProvider type="XML" validate="true" path="security-policy.xml"/>

    <!-- Low-level configuration about protocols and bindings available for use. -->
    <ProtocolProvider type="XML" validate="true" reloadChanges="false" path="protocols.xml"/>


</SPConfig>
