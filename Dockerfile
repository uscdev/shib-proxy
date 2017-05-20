FROM virtualstaticvoid/shibboleth-nginx

COPY shibboleth/shibboleth2.xml /etc/shibboleth
COPY shibboleth/shibboleth2.xml.tpl /etc/shibboleth
COPY shibboleth/USC-metadata.xml /etc/shibboleth
