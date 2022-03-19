<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:sinopia="http://sinopia.io/vocabulary/"
    xmlns:maps="https://uwlib-cams.github.io/map_storage/"
    xmlns:bmrxml="https://briesenberg07.github.io/xml_stack/"
    xmlns:reg="http://metadataregistry.org/uri/profile/regap/"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <!-- Store RDA Registry prop files in vars (just a couple for testing; 13 total for implementation later) -->
    <!-- TO DO iterate over these docs, don't repeat result-doc elements as below -->
    <xsl:variable name="get_prop_sets"
        select="document('https://github.com/uwlib-cams/map_storage/raw/main/get_prop_sets.xml')"/>    
    
    <xsl:template name="multiple_property_iris">
        <xsl:param name="prop"/>
        <!-- determine whether the prop is RDA or some other -->
        <!-- then get either selected iris (each maps:property), or all subprop iris (iterate over corresponding RDA Reg file -->
        <xsl:choose>
            <!-- for RDA PTs -->
            <xsl:when test="starts-with($prop/maps:prop_iri/@iri, 'http://rdaregistry.info')">
                <xsl:choose>
                    <!-- when the implementation set contains a list of props, put each in the PT -->
                    <xsl:when test="$prop/maps:sinopia/maps:implementation_set/
                        maps:multiple_prop/maps:property/node()">
                        <sinopia:hasPropertyUri rdf:resource="{$prop/maps:prop_iri/@iri}"/>
                        <xsl:for-each select="$prop/maps:sinopia/maps:implementation_set/
                            maps:multiple_prop/maps:property">
                            <!-- I'll retrieve label separately -->
                            <sinopia:hasPropertyUri rdf:resource="{@property_iri}"/>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- when the implementation set says to to put all subprops in the PT, get these and put them in -->
                    <xsl:when test="matches($prop/maps:sinopia/maps:implementation_set/
                        maps:multiple_prop/maps:all_subprops, 'true|1')">
                        <xsl:variable name="rda_prop_set">
                            <xsl:choose>
                                <xsl:when test="starts-with(
                                    substring-after($prop/maps:prop_iri/@iri, 'http://rdaregistry.info/Elements/'),
                                    'w')">rdacWork</xsl:when>
                                <xsl:when test="starts-with(
                                    substring-after($prop/maps:prop_iri/@iri, 'http://rdaregistry.info/Elements/'),
                                    'e')">rdacExpression</xsl:when>
                                <xsl:when test="starts-with(
                                    substring-after($prop/maps:prop_iri/@iri, 'http://rdaregistry.info/Elements/'),
                                    'm')">rdacManifestation</xsl:when>
                                <xsl:when test="starts-with(
                                    substring-after($prop/maps:prop_iri/@iri, 'http://rdaregistry.info/Elements/'),
                                    'i')">rdacItem</xsl:when>
                                <!-- ... TO DO  -->
                            </xsl:choose>
                        </xsl:variable>
                        <sinopia:hasPropertyUri rdf:resource="{$prop/maps:prop_iri/@iri}"/>
                        <xsl:for-each select="
                            document($get_prop_sets/maps:get_set[maps:set_name = $rda_prop_set]/maps:set_source)/
                            rdf:RDF/rdf:Description
                            [rdfs:subPropertyOf/@rdf:resource = $prop/maps:prop_iri/@iri]
                            [not(reg:status[@rdf:resource = 'http://metadataregistry.org/uri/RegStatus/1008'])]">
                            <sinopia:hasPropertyUri rdf:resource="{@rdf:about}"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>ERROR - NEITHER PROPERTY ELEMENTS OR ALL_SUBPROPS ELEMENT IN SOURCE</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- when - for other-ontology PTs (TO DO LATER) -->
            <xsl:otherwise>
                <xsl:text>ERROR - MULTIPLE-PROPERTY PTs NOT CONFIGURED FOR THIS SOURCE</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <!-- to do need to call multiple_property_labels template -->
    </xsl:template>
    
    <xsl:template name="multiple_property_labels">
        <xsl:param name="prop"/>
        <!-- determine whether the prop is RDA or some other -->
        <!-- then get either selected prop labels (each maps:property), or all subprop iris (iterate over corresponding RDA Reg file -->
        <xsl:choose>
            <!-- for RDA PTs -->
            <xsl:when test="starts-with($prop/maps:prop_iri/@iri, 'http://rdaregistry.info')">
                <xsl:choose>
                    <!-- when the implementation set contains a list of props with labels, put each in the PT -->
                    <xsl:when test="$prop/maps:sinopia/maps:implementation_set/
                        maps:multiple_prop/maps:property/node()">
                        <rdf:Description rdf:about="{$prop/maps:prop_iri/@iri}">
                            <rdfs:label xml:lang="{$prop/maps:prop_label/@xml:lang}">
                                <xsl:value-of select="$prop/maps:prop_label"/>
                            </rdfs:label>
                        </rdf:Description>
                        <xsl:for-each select="$prop/maps:sinopia/maps:implementation_set/
                            maps:multiple_prop/maps:property">
                            <rdf:Description rdf:about="{@property_iri}">
                                <rdfs:label xml:lang="{@xml:lang}">
                                    <xsl:value-of select="."/>
                                </rdfs:label>
                            </rdf:Description>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- when the implementation set says to to put all subprops in the PT, get labels for all of these and put them in -->
                    <xsl:when test="matches($prop/maps:sinopia/maps:implementation_set/
                        maps:multiple_prop/maps:all_subprops, 'true|1')">
                        <!-- ...TO DO  -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- for other-ontology PTs (TO DO LATER) -->
            <xsl:otherwise>
                <xsl:text>>ERROR - MULTIPLE-PROPERTY PTs NOT CONFIGURED FOR THIS SOURCE</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>