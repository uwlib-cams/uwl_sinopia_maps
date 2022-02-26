<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:sinopia="http://sinopia.io/vocabulary/"
    xmlns:maps="https://uwlib-cams.github.io/map_storage/"
    xmlns:bmrxml="https://briesenberg07.github.io/xml_stack/" exclude-result-prefixes="xs"
    version="3.0">
    
    <!-- (there must be a better way to reuse a function than copying and renaming in each file??) -->
    <xsl:function name="bmrxml:rda_iri_slug_define_lookup">
        <xsl:param name="path_to_iri"/>
        <xsl:value-of select="translate(substring-after($path_to_iri, 'Elements/'), '/', '_')"/>
    </xsl:function>
    
    <!-- output uri or lookup > lookup PT attributes -->
    <xsl:template name="define_lookup_pts">
        <xsl:param name="prop"/>
        <rdf:Description
            rdf:nodeID="{concat(bmrxml:rda_iri_slug_define_lookup($prop/maps:prop_iri/@iri),
            '_lookup_attributes')}">
            <!-- hard-code rdf:type for this node sinopia:LookupPropertyTemplate-->
            <rdf:type rdf:resource="http://sinopia.io/vocabulary/LookupPropertyTemplate"/>
            <xsl:for-each select="
                $prop/maps:sinopia/maps:implementation_set/maps:sinopia_prop_attributes/
                maps:sinopia_prop_type_attributes/maps:lookup_attributes/maps:authorities/maps:authority_urn">
                <sinopia:hasAuthority rdf:resource="{.}"/>
            </xsl:for-each>
        </rdf:Description>
        <!-- map_storage doesn't allow for assigning labels to authority URNs, so no URN label output -->
    </xsl:template>
    
</xsl:stylesheet>