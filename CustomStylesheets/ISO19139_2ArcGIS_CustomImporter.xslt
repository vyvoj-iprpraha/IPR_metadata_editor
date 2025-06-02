<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" 
  exclude-result-prefixes="gmd gco gmi gml gmx gts srv xlink xsi xsl t esri res msxsl" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:gmi="http://www.isotc211.org/2005/gmi"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:gmx="http://www.isotc211.org/2005/gmx" 
  xmlns:gts="http://www.isotc211.org/2005/gts" 
  xmlns:srv="http://www.isotc211.org/2005/srv" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:t="http://www.esri.com/xslt/translator" 
  xmlns:esri="http://www.esri.com/metadata/" 
  xmlns:res="http://www.esri.com/metadata/res/" 
  xmlns:msxsl="urn:schemas-microsoft-com:xslt">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

  <xsl:key name="ctryName" match="country" use="name"/>
  <xsl:key name="ctrya3" match="country" use="@alpha3"/>

  <xsl:key name="langName" match="language" use="name"/>
  <xsl:key name="langa2" match="language" use="@alpha2"/>
  <xsl:key name="langa3" match="language" use="@alpha3"/>
  <xsl:key name="langa3t" match="language" use="@alpha3t"/>
 
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:variable name="codes">
    <xsl:copy-of select="document('codes.xml')/*" />
  </xsl:variable>
  <xsl:variable name="countries_3166" select="msxsl:node-set($codes)/codes/countryCodes" />
  <xsl:variable name="languages_632" select="msxsl:node-set($codes)/codes/languageCodes" />

  <xsl:template match="/gmi:MI_Metadata | /gmd:MD_Metadata">
    <metadata>
      <Esri>
        <ArcGISFormat>1.0</ArcGISFormat>
        <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[(gmd:thesaurusName/@uuidref='723f6998-058e-11dc-8314-0800200c9a66')]/gmd:keyword/gco:CharacterString[. != '']">
          <DataProperties>
            <itemProps>
              <imsContentType>
                <xsl:call-template name="contentTypeCode">
                  <xsl:with-param name="source"><xsl:value-of select="."/></xsl:with-param> 
                </xsl:call-template>
              </imsContentType>
            </itemProps>
          </DataProperties>
        </xsl:for-each>
        <xsl:if test="(local-name(.) = 'MD_Metadata') and (gmd:locale/gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue != '')">
          <locales>
            <xsl:call-template name="Locales" />
          </locales>
        </xsl:if>
        <xsl:if test="(local-name(.) = 'MD_Metadata') and (gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer != '') and (count(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer) >1)">
          <xsl:variable name="scale" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction" />
          <scaleRange>
            <xsl:for-each select="$scale">
              <xsl:sort select="gmd:denominator/gco:Integer" data-type="number" order="descending"/>
              <xsl:if test="position() = last()">
                <maxScale><xsl:value-of select="gmd:denominator/gco:Integer" /></maxScale>
              </xsl:if>
              <xsl:if test="position() = 1">
                <minScale><xsl:value-of select="gmd:denominator/gco:Integer" /></minScale>
              </xsl:if>
            </xsl:for-each>
          </scaleRange>
        </xsl:if>
      </Esri>

      <xsl:if test="(local-name(.) = 'MD_Metadata')">
        <xsl:call-template name="metadataContent" />
      </xsl:if>
    </metadata>
  </xsl:template>
  
  <!-- Locales -->
  <xsl:template name="Locales">
    <xsl:for-each select="gmd:locale/gmd:PT_Locale">
      <xsl:variable name="lang"><xsl:value-of select="gmd:languageCode/gmd:LanguageCode/@codeListValue" /></xsl:variable>
      <xsl:variable name="cntry"><xsl:value-of select="gmd:country/gmd:Country/@codeListValue" /></xsl:variable>
      <xsl:variable name="locale"><xsl:value-of select="$lang" />-<xsl:value-of select="$cntry" /></xsl:variable>
      <locale>
        <xsl:attribute name="language"><xsl:value-of select="$lang" /></xsl:attribute>
        <xsl:attribute name="country"><xsl:value-of select="$cntry" /></xsl:attribute>
        <xsl:for-each select="../../gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $locale]">
          <title><xsl:value-of select="." /></title>
        </xsl:for-each>
        <xsl:for-each select="../../gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $locale]">
          <abstract><xsl:value-of select="." /></abstract>
        </xsl:for-each>
      </locale>
    </xsl:for-each>
  </xsl:template>
  
  
  <!-- B.2.1 Metadata entity set information -->

  <!-- MD_Metadata -->
  <xsl:template name="metadataContent">
      <xsl:for-each select="gmd:fileIdentifier/gco:CharacterString[(. != '')]">
        <mdFileID><xsl:value-of select="." /></mdFileID>
      </xsl:for-each>
      <xsl:for-each select="gmd:language[(gco:CharacterString) or (gmd:LanguageCode)]">
        <mdLang>
          <xsl:for-each select="gco:CharacterString">
            <xsl:variable name="lowerValue" select="translate(., $upper, $lower)" />
            <languageCode>
              <xsl:attribute name="value">
                <xsl:apply-templates select="$languages_632">
                  <xsl:with-param name="lower" select="$lowerValue" />
                  <xsl:with-param name="original" select="." />
                </xsl:apply-templates>
              </xsl:attribute>
            </languageCode>
          </xsl:for-each>
          <xsl:for-each select="gmd:LanguageCode">
            <languageCode>
              <xsl:attribute name="value"><xsl:value-of select="@codeListValue" /></xsl:attribute>
            </languageCode>
          </xsl:for-each>
        </mdLang>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="gmd:characterSet/gmd:MD_CharacterSetCode">
          <xsl:for-each select="gmd:characterSet/gmd:MD_CharacterSetCode">
            <mdChar>
              <CharSetCd>
                <xsl:attribute name="value">
                  <xsl:call-template name="MD_CharacterSetCode">
                    <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
                  </xsl:call-template>
                </xsl:attribute>
              </CharSetCd>
            </mdChar>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <mdChar>
            <CharSetCd>
              <xsl:attribute name="value">
                <xsl:call-template name="MD_CharacterSetCode">
                  <xsl:with-param name="source">utf8</xsl:with-param> 
                </xsl:call-template>
              </xsl:attribute>
            </CharSetCd>
          </mdChar>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="gmd:parentIdentifier/gco:CharacterString">
        <mdParentID><xsl:value-of select="." /></mdParentID>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="gmd:hierarchyLevel/gmd:MD_ScopeCode">
          <xsl:for-each select="gmd:hierarchyLevel/gmd:MD_ScopeCode">
            <mdHrLv>
              <ScopeCd>
                <xsl:attribute name="value">
                  <xsl:call-template name="MD_ScopeCode">
                    <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
                  </xsl:call-template>
                </xsl:attribute>
              </ScopeCd>
            </mdHrLv>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <mdHrLv>
            <ScopeCd>
              <xsl:attribute name="value">
                <xsl:call-template name="MD_ScopeCode">
                  <xsl:with-param name="source">dataset</xsl:with-param> 
                </xsl:call-template>
              </xsl:attribute>
            </ScopeCd>
          </mdHrLv>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="gmd:hierarchyLevelName/gco:CharacterString">
        <mdHrLvName><xsl:value-of select="." /></mdHrLvName>
      </xsl:for-each>
      <xsl:for-each select="gmd:contact/gmd:CI_ResponsibleParty">
        <mdContact>
          <xsl:call-template name="CI_ResponsibleParty">
            <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
          </xsl:call-template>
        </mdContact>
      </xsl:for-each>
      <xsl:for-each select="gmd:dateStamp">
        <xsl:for-each select="gco:Date">
          <mdDateSt><xsl:value-of select="translate(.,'-','')" /></mdDateSt>
        </xsl:for-each>
        <xsl:for-each select="gco:DateTime">
          <mdDateSt><xsl:value-of select="translate(substring-before(.,'T'),'-','')" /></mdDateSt>
        </xsl:for-each>
      </xsl:for-each>
      <mdStanName>
        <xsl:text>ArcGIS Metadata</xsl:text>
      </mdStanName>
      <mdStanVer>
        <xsl:text>1.0</xsl:text>
      </mdStanVer>
      <xsl:for-each select="gmd:dataSetURI/gco:CharacterString">
        <dataSetURI><xsl:value-of select="." /></dataSetURI>
      </xsl:for-each>

      <xsl:for-each select="gmd:spatialRepresentationInfo/child::*">
        <spatRepInfo>
          <xsl:call-template name="MD_SpatialRepresentation" />
        </spatRepInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
        <refSysInfo>
          <RefSystem>
            <refSysID>
              <xsl:call-template name="RS_Identifier" />
            </refSysID>
          </RefSystem>
        </refSysInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation">
        <mdExtInfo>
          <xsl:call-template name="MD_MetadataExtensionInformation" />
        </mdExtInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:identificationInfo[1]">
        <xsl:for-each select="gmd:MD_DataIdentification">
          <dataIdInfo>
            <xsl:call-template name="MD_DataIdentification" />
          </dataIdInfo>
        </xsl:for-each>
        <xsl:for-each select="srv:SV_ServiceIdentification">
          <dataIdInfo>
            <xsl:call-template name="SV_ServiceIdentification" />
          </dataIdInfo>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:for-each select="gmd:contentInfo/child::*">
        <contInfo>
          <xsl:call-template name="MD_ContentInformation" />
        </contInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
        <distInfo>
          <xsl:call-template name="MD_Distribution" />
        </distInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:dataQualityInfo/gmd:DQ_DataQuality">
        <dqInfo>
          <xsl:call-template name="DQ_DataQuality" />
        </dqInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:portrayalCatalogueInfo/gmd:MD_PortrayalCatalogueReference">
        <porCatInfo>
          <xsl:call-template name="MD_PortrayalCatalogueReference" />
        </porCatInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:metadataConstraints">
        <mdConst>
          <xsl:call-template name="MD_Constraints" />
        </mdConst>
      </xsl:for-each>
      <xsl:for-each select="gmd:applicationSchemaInfo/gmd:MD_ApplicationSchemaInformation">
        <appSchInfo>
          <xsl:call-template name="MD_ApplicationSchemaInformation" />
        </appSchInfo>
      </xsl:for-each>
      <xsl:for-each select="gmd:metadataMaintenance/gmd:MD_MaintenanceInformation">
        <mdMaint>
          <xsl:call-template name="MD_MaintenanceInformation" />
        </mdMaint>
      </xsl:for-each>
  </xsl:template>
  

  <!-- B.2.2 Identification information (includes data and service identification) -->
  
  <!-- B.2.2.1 General identification information -->
  <!-- MD_Identification -->
  <xsl:template name="MD_Identification">
    <xsl:for-each select="gmd:citation/gmd:CI_Citation">
      <idCitation>
        <xsl:call-template name="CI_Citation"/>
      </idCitation>
    </xsl:for-each>
    <xsl:for-each select="gmd:abstract/gco:CharacterString">
      <idAbs><xsl:value-of select="."/></idAbs>
    </xsl:for-each>
    <xsl:for-each select="gmd:purpose/gco:CharacterString">
      <idPurp><xsl:value-of select="."/></idPurp>
    </xsl:for-each>
    <xsl:for-each select="gmd:credit/gco:CharacterString">
      <idCredit><xsl:value-of select="."/></idCredit>
    </xsl:for-each>
    <xsl:for-each select="gmd:status/gmd:MD_ProgressCode">
      <idStatus>
        <ProgCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_ProgressCode">
              <xsl:with-param name="source" select="@codeListValue" />
            </xsl:call-template>
          </xsl:attribute>
        </ProgCd>
      </idStatus>
    </xsl:for-each>
    <xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty">
      <idPoC>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </idPoC>
    </xsl:for-each>
    <xsl:for-each select="gmd:resourceMaintenance/gmd:MD_MaintenanceInformation">
      <resMaint>
        <xsl:call-template name="MD_MaintenanceInformation" />
      </resMaint>
    </xsl:for-each>
    <xsl:for-each select="gmd:graphicOverview/gmd:MD_BrowseGraphic">
      <graphOver>
        <xsl:call-template name="MD_BrowseGraphic" />
      </graphOver>
    </xsl:for-each>
    <xsl:for-each select="gmd:resourceFormat/gmd:MD_Format">
      <dsFormat>
        <xsl:call-template name="MD_Format"/>
      </dsFormat>
    </xsl:for-each>
    
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='discipline']">
      <discKeys>
        <xsl:call-template name="MD_Keywords" />
      </discKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='place']">
      <placeKeys>
        <xsl:call-template name="MD_Keywords" />
      </placeKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='stratum']">
      <stratKeys>
        <xsl:call-template name="MD_Keywords" />
      </stratKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='temporal']">
      <tempKeys>
        <xsl:call-template name="MD_Keywords" />
      </tempKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='theme']">
      <themeKeys>
        <xsl:call-template name="MD_Keywords" />
      </themeKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='subTopicCategory']">
      <subTopicCatKeys>
        <xsl:call-template name="MD_Keywords" />
      </subTopicCatKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='product']">
      <productKeys>
        <xsl:call-template name="MD_Keywords" />
      </productKeys>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[(count(gmd:type/gmd:MD_KeywordTypeCode)=0) and not(gmd:thesaurusName/@uuidref = '723f6998-058e-11dc-8314-0800200c9a66')]">
      <otherKeys>
        <xsl:call-template name="MD_Keywords" />
      </otherKeys>
    </xsl:for-each>
    <xsl:if test="gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/@uuidref = '723f6998-058e-11dc-8314-0800200c9a66')]/gmd:keyword[. != '']">
      <searchKeys>
        <xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/@uuidref = '723f6998-058e-11dc-8314-0800200c9a66')]/gmd:keyword">
          <keyword><xsl:value-of select="gco:CharacterString"/></keyword>
        </xsl:for-each>
      </searchKeys>
    </xsl:if>

    <xsl:for-each select="gmd:resourceSpecificUsage/gmd:MD_Usage">
      <idSpecUse>
        <xsl:call-template name="MD_Usage" />
      </idSpecUse>
    </xsl:for-each>
    <xsl:for-each select="gmd:resourceConstraints">
      <resConst>
        <xsl:call-template name="MD_Constraints" />
      </resConst>
    </xsl:for-each>
    <xsl:for-each select="gmd:aggregationInfo/gmd:MD_AggregateInformation">
      <aggrInfo>
        <xsl:call-template name="MD_AggregateInformation" />
      </aggrInfo>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MD_DataIdentification -->
  <xsl:template name="MD_DataIdentification">
    <xsl:call-template name="MD_Identification" />

    <xsl:for-each select="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
      <spatRpType>
        <SpatRepTypCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_SpatialRepresentationTypeCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
            </xsl:call-template>
          </xsl:attribute>
        </SpatRepTypCd>
      </spatRpType>
    </xsl:for-each>
    <xsl:if test="gmd:spatialResolution/gmd:MD_Resolution[. != '']">
      <dataScale>
        <xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
          <xsl:call-template name="MD_Resolution" />
        </xsl:for-each>
      </dataScale>
    </xsl:if>
    <xsl:for-each select="gmd:language[(gco:CharacterString) or (gmd:LanguageCode)]">
      <dataLang>
        <xsl:for-each select="gco:CharacterString">
          <xsl:variable name="lowerValue" select="translate(., $upper, $lower)" />
          <languageCode>
            <xsl:attribute name="value">
              <xsl:apply-templates select="$languages_632">
                <xsl:with-param name="lower" select="$lowerValue" />
                <xsl:with-param name="original" select="." />
              </xsl:apply-templates>
            </xsl:attribute>
          </languageCode>
        </xsl:for-each>
        <xsl:for-each select="gmd:LanguageCode">
          <languageCode>
            <xsl:attribute name="value"><xsl:value-of select="@codeListValue" /></xsl:attribute>
          </languageCode>
        </xsl:for-each>
        <xsl:for-each select="gmd:Country">
          <countryCode>
            <xsl:attribute name="value"><xsl:value-of select="@codeListValue" /></xsl:attribute>
          </countryCode>
        </xsl:for-each>
      </dataLang>
    </xsl:for-each>
    <xsl:for-each select="gmd:characterSet/gmd:MD_CharacterSetCode">
      <dataChar>
        <CharSetCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_CharacterSetCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
            </xsl:call-template>
          </xsl:attribute>
        </CharSetCd>
      </dataChar>
    </xsl:for-each>
    <xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
      <tpCat>
        <TopicCatCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_TopicCategoryCode">
              <xsl:with-param name="source"><xsl:value-of select="." /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </TopicCatCd>
      </tpCat>
    </xsl:for-each>
    <xsl:for-each select="gmd:environmentDescription/gco:CharacterString">
      <envirDesc><xsl:value-of select="."/></envirDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:extent/gmd:EX_Extent">
      <dataExt>
        <xsl:call-template name="EX_Extent" />
      </dataExt>
    </xsl:for-each>
    <xsl:for-each select="gmd:supplementalInformation/gco:CharacterString">
      <suppInfo><xsl:value-of select="." /></suppInfo>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.2.2 Browse graphic information -->
  <!-- MD_BrowseGraphic -->
  <xsl:template name="MD_BrowseGraphic">
    <xsl:for-each select="gmd:fileName/gco:CharacterString">
      <bgFileName><xsl:value-of select="."/></bgFileName>
    </xsl:for-each>
    <xsl:for-each select="gmd:fileDescription/gco:CharacterString">
      <bgFileDesc><xsl:value-of select="."/></bgFileDesc>    
    </xsl:for-each>
    <xsl:for-each select="gmd:fileType/gco:CharacterString">
      <bgFileType><xsl:value-of select="."/></bgFileType>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.2.3 Keyword information -->
  <!-- MD_Keywords -->
  <xsl:template name="MD_Keywords">
    <xsl:for-each select="gmd:keyword">
      <keyword><xsl:value-of select="gco:CharacterString"/></keyword>
    </xsl:for-each>
    <xsl:for-each select="gmd:thesaurusName/gmd:CI_Citation">
      <thesaName>
        <xsl:call-template name="CI_Citation" />
      </thesaName>
    </xsl:for-each>
    <!--
    <thesaLang>
      <languageCode>
        <xsl:variable name="value"><xsl:value-of select="gmd:languageCode/@codeListValue" /></xsl:variable>
      </languageCode>
      <countryCode>
        <xsl:variable name="value"><xsl:value-of select="gmd:languageCode/@codeListValue" /></xsl:variable>
      </countryCode>
    </thesaLang>
      -->
  </xsl:template>
  
  <!-- B.2.2.4 Representative fraction information -->
  <!-- MD_RepresentativeFraction -->
  <xsl:template name="MD_RepresentativeFraction">
    <xsl:for-each select="gmd:denominator/gco:Integer">
      <rfDenom><xsl:value-of select="."/></rfDenom>
    </xsl:for-each>
  </xsl:template>

  <!-- B.2.2.5 Resolution information -->
  <!-- MD_Resolution -->
  <xsl:template name="MD_Resolution">
    <xsl:for-each select="gmd:equivalentScale/gmd:MD_RepresentativeFraction">
      <equScale>
        <xsl:call-template name="MD_RepresentativeFraction" />
      </equScale>
    </xsl:for-each>
    <xsl:for-each select="gmd:distance/gco:Distance">
      <scaleDist>
        <value>
          <xsl:attribute name="uom"><xsl:value-of select="@uom"/></xsl:attribute>
          <xsl:value-of select="."/>
        </value>
      </scaleDist>
    </xsl:for-each>    
  </xsl:template>
  
  <!-- B.2.2.6 Usage information -->
  <!-- MD_Usage -->
  <xsl:template name="MD_Usage">
    <xsl:for-each select="gmd:specificUsage/gco:CharacterString">
      <specUsage><xsl:value-of select="."/></specUsage>
    </xsl:for-each>
    <xsl:for-each select="gmd:usageDateTime/gco:DateTime">
      <usageDate><xsl:value-of select="."/></usageDate>
    </xsl:for-each>
    <xsl:for-each select="gmd:userDeterminedLimitations/gco:CharacterString">
      <usrDetLim><xsl:value-of select="."/></usrDetLim>
    </xsl:for-each>
    <xsl:for-each select="gmd:userContactInfo/gmd:CI_ResponsibleParty">
      <usrCntInfo>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </usrCntInfo>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.2.7 Aggregation information -->
  <!-- MD_AggregateInformation -->
  <xsl:template name="MD_AggregateInformation">
    <xsl:for-each select="gmd:aggregateDataSetName/gmd:CI_Citation">
      <aggrDSName>
        <xsl:call-template name="CI_Citation" />
      </aggrDSName>
    </xsl:for-each>
    <xsl:for-each select="gmd:aggregateDataSetIdentifier/gmd:MD_Identifier">
      <aggrDSIdent>
        <xsl:call-template name="MD_Identifier" />
      </aggrDSIdent>
    </xsl:for-each>
    <xsl:for-each select="gmd:associationType/gmd:DS_AssociationTypeCode">
      <assocType>
        <AscTypeCd>
          <xsl:attribute name="value">
            <xsl:call-template name="DS_AssociationTypeCode">
              <xsl:with-param name="source" select="@codeListValue" />
            </xsl:call-template>
          </xsl:attribute>
        </AscTypeCd>
      </assocType>
    </xsl:for-each>
    <xsl:for-each select="gmd:initiativeType/gmd:DS_InitiativeTypeCode">
      <initType>
        <InitTypCd>
          <xsl:attribute name="value">
            <xsl:call-template name="DS_InitiativeTypeCode">
              <xsl:with-param name="source" select="@codeListValue" />
            </xsl:call-template>
          </xsl:attribute>
        </InitTypCd>
      </initType>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.3 Constraint information (includes legal and security) -->
  <!-- MD_Constraints -->
  <xsl:template name="MD_Constraints">
    <xsl:for-each select="gmd:MD_Constraints">
      <Consts>
        <xsl:for-each select="gmd:useLimitation/gco:CharacterString">
          <useLimit><xsl:value-of select="." /></useLimit>
        </xsl:for-each>
      </Consts>
    </xsl:for-each>
    <xsl:for-each select="gmd:MD_LegalConstraints">
      <LegConsts>
        <xsl:call-template name="MD_LegalConstraints" />
      </LegConsts>
    </xsl:for-each>
    <xsl:for-each select="gmd:MD_SecurityConstraints">
      <SecConsts>
        <xsl:call-template name="MD_SecurityConstraints" />
      </SecConsts>
    </xsl:for-each>
  </xsl:template>

  <!-- MD_SecurityConstraints -->
  <xsl:template name="MD_SecurityConstraints">
    <xsl:for-each select="gmd:useLimitation/gco:CharacterString">
      <useLimit><xsl:value-of select="." /></useLimit>
    </xsl:for-each>
    <xsl:for-each select="gmd:classification/gmd:MD_ClassificationCode">
      <class>
        <ClasscationCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_ClassificationCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
            </xsl:call-template>
          </xsl:attribute>
        </ClasscationCd>
      </class>
    </xsl:for-each>
    <xsl:for-each select="gmd:userNote/gco:CharacterString">
      <userNote>
        <xsl:value-of select="." />
      </userNote>
    </xsl:for-each>
    <xsl:for-each select="gmd:classificationSystem/gco:CharacterString">
      <classSys>
        <xsl:value-of select="." />
      </classSys>
    </xsl:for-each>
    <xsl:for-each select="gmd:handlingDescription/gco:CharacterString">
      <handDesc>
        <xsl:value-of select="." />
      </handDesc>
    </xsl:for-each>
  </xsl:template>

  <!-- MD_LegalConstraints -->
  <xsl:template name="MD_LegalConstraints">
    <xsl:for-each select="gmd:useLimitation/gco:CharacterString">
      <useLimit><xsl:value-of select="." /></useLimit>
    </xsl:for-each>
    <xsl:for-each select="gmd:accessConstraints/gmd:MD_RestrictionCode">
      <accessConsts>
        <RestrictCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_RestrictionCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
            </xsl:call-template>
          </xsl:attribute>
        </RestrictCd>
      </accessConsts>
    </xsl:for-each>
    <xsl:for-each select="gmd:useConstraints/gmd:MD_RestrictionCode">
      <useConsts>
        <RestrictCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_RestrictionCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param> 
            </xsl:call-template>
          </xsl:attribute>
        </RestrictCd>
      </useConsts>
    </xsl:for-each>
    <xsl:for-each select="gmd:otherConstraints/gco:CharacterString">
      <othConsts><xsl:value-of select="." /></othConsts>
    </xsl:for-each>
    <xsl:for-each select="gmd:otherConstraints/gmx:Anchor">
      <xsl:variable name="PublicAccessURL">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/</xsl:variable>
      <xsl:variable name="ConditionsUseURL">http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/</xsl:variable>
      <xsl:choose>
        <xsl:when test="(starts-with(@xlink:href,$PublicAccessURL))">
          <inspirePublicAccessLimits>
            <PublicAccessCd>
              <xsl:attribute name="value">
                <xsl:call-template name="LimitationsOnPublicAccess">
                  <xsl:with-param name="source"><xsl:value-of select="substring-after(@xlink:href,$PublicAccessURL)"/></xsl:with-param> 
                </xsl:call-template>
              </xsl:attribute>
            </PublicAccessCd>
          </inspirePublicAccessLimits>
        </xsl:when>
        <xsl:when test="(starts-with(@xlink:href,$ConditionsUseURL))">
          <inspireAccessUseConditions>
            <ConditionsAccUseCd>
              <xsl:attribute name="value">
                <xsl:call-template name="ConditionsApplyingToAccessAndUse">
                  <xsl:with-param name="source"><xsl:value-of select="substring-after(@xlink:href,$ConditionsUseURL)"/></xsl:with-param> 
                </xsl:call-template>
              </xsl:attribute>
            </ConditionsAccUseCd>
          </inspireAccessUseConditions>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- B.2.4 Data quality information -->
  <!-- B.2.4.1 General data quality information -->
  <!-- DQ_DataQuality -->
  <xsl:template name="DQ_DataQuality">
    <xsl:for-each select="gmd:scope/gmd:DQ_Scope">
      <dqScope>
        <xsl:call-template name="DQ_Scope" />
      </dqScope>
    </xsl:for-each>
    <xsl:for-each select="gmd:report/child::*">
      <report>
        <xsl:call-template name="DQ_Element" />
      </report>
    </xsl:for-each>
    <xsl:for-each select="gmd:lineage/gmd:LI_Lineage">
      <dataLineage>
        <xsl:call-template name="LI_Lineage" />
      </dataLineage>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.4.2 Lineage information -->
  <!-- B.2.4.2.1 General lineage information-->
  <!-- LI_Lineage -->
  <xsl:template name="LI_Lineage">
    <xsl:for-each select="gmd:statement/gco:CharacterString">
      <statement><xsl:value-of select="." /></statement>
    </xsl:for-each>
    <xsl:for-each select="gmd:processStep/gmd:LI_ProcessStep">
      <prcStep>
        <xsl:call-template name="LI_ProcessStep" />
      </prcStep>
    </xsl:for-each>
    <xsl:for-each select="gmd:source/gmd:LI_Source">
      <dataSource>
        <xsl:call-template name="LI_Source" />
      </dataSource>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.4.2.2 Process step information -->
  <!-- LI_ProcessStep -->
  <xsl:template name="LI_ProcessStep">
    <xsl:for-each select="gmd:description/gco:CharacterString">
      <stepDesc><xsl:value-of select="." /></stepDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:rationale/gco:CharacterString">
      <stepRat><xsl:value-of select="." /></stepRat>
    </xsl:for-each>
    <xsl:for-each select="gmd:dateTime/gco:DateTime">
      <stepDateTm><xsl:value-of select="." /></stepDateTm>
    </xsl:for-each>
    <xsl:for-each select="gmd:processor/gmd:CI_ResponsibleParty">
      <stepProc>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </stepProc>
    </xsl:for-each>
    <xsl:for-each select="gmd:source/gmd:LI_Source">
      <stepSrc>
        <xsl:call-template name="LI_Source" />
      </stepSrc>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.4.2.3 Source information -->
  <!-- LI_Source -->
  <xsl:template name="LI_Source">
    <xsl:for-each select="gmd:description/gco:CharacterString">
      <srcDesc><xsl:value-of select="." /></srcDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:scaleDenominator/gmd:MD_RepresentativeFraction">
      <srcScale>
        <xsl:call-template name="MD_RepresentativeFraction" />
      </srcScale>
    </xsl:for-each>
    <xsl:for-each select="gmd:sourceReferenceSystem/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
      <srcRefSys>
        <xsl:call-template name="RS_Identifier" />
      </srcRefSys>
    </xsl:for-each>
    <xsl:for-each select="gmd:sourceCitation/gmd:CI_Citation">
      <srcCitatn>
        <xsl:call-template name="CI_Citation" />
      </srcCitatn>
    </xsl:for-each>
    <xsl:for-each select="gmd:sourceExtent/gmd:EX_Extent">
      <srcExt>
        <xsl:call-template name="EX_Extent" />
      </srcExt>
    </xsl:for-each>
    <xsl:for-each select="gmd:sourceStep/gmd:LI_ProcessStep">
      <srcStep>
        <xsl:call-template name="LI_ProcessStep" />
      </srcStep>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.4.3 Data quality element information -->
  <!-- DQ_Element -->
  <xsl:template name="DQ_Element">
    <xsl:attribute name="type">
      <xsl:call-template name="DQ_ElementType">
        <xsl:with-param name="source"><xsl:value-of select="local-name()" /></xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:for-each select="gmd:nameOfMeasure/gco:CharacterString">
      <measName><xsl:value-of select="." /></measName>
    </xsl:for-each>
    <xsl:for-each select="gmd:measureIdentification/gmd:MD_Identifier">
      <measId>
        <xsl:call-template name="MD_Identifier" />
      </measId>
    </xsl:for-each>
    <xsl:for-each select="gmd:measureDescription/gco:CharacterString">
      <measDesc><xsl:value-of select="." /></measDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:evaluationMethodType/gmd:DQ_EvaluationMethodTypeCode">
      <evalMethType>
        <EvalMethTypeCd>
          <xsl:attribute name="value">
            <xsl:call-template name="DQ_EvaluationMethodTypeCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </EvalMethTypeCd>
      </evalMethType>
    </xsl:for-each>
    <xsl:for-each select="gmd:evaluationMethodDescription/gco:CharacterString">
      <evalMethDesc><xsl:value-of select="." /></evalMethDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:evaluationProcedure/gmd:CI_Citation">
      <evalProc>
        <xsl:call-template name="CI_Citation" />
      </evalProc>
    </xsl:for-each>
    <xsl:for-each select="gmd:dateTime/gco:DateTime">
      <measDateTm><xsl:value-of select="." /></measDateTm>
    </xsl:for-each>
    <xsl:for-each select="gmd:result[child::* !='']">
      <measResult>
        <xsl:call-template name="DQ_Result" />
      </measResult>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.4.4 Result information -->
  <!-- DQ_Result -->
  <xsl:template name="DQ_Result">
    <xsl:for-each select="gmd:DQ_ConformanceResult">
      <ConResult>
        <xsl:call-template name="DQ_ConformanceResult" />
      </ConResult>
    </xsl:for-each>
    <xsl:for-each select="gmd:DQ_QuantitativeResult">
      <QuanResult>
        <xsl:call-template name="DQ_QuantitativeResult" />
      </QuanResult>
    </xsl:for-each>
  </xsl:template>

  <!-- DQ_ConformanceResult -->
  <xsl:template name="DQ_ConformanceResult">
    <xsl:for-each select="gmd:specification/gmd:CI_Citation">
      <conSpec>
        <xsl:call-template name="CI_Citation" />
      </conSpec>
    </xsl:for-each>
    <xsl:for-each select="gmd:explanation/gco:CharacterString">
      <conExpl><xsl:value-of select="." /></conExpl>
    </xsl:for-each>
    <xsl:for-each select="gmd:pass/gco:Boolean">
      <conPass><xsl:value-of select="." /></conPass>
    </xsl:for-each>
  </xsl:template>
  
  <!-- DQ_QuantitativeResult -->
  <xsl:template name="DQ_QuantitativeResult">
    <xsl:for-each select="gmd:valueType/gco:RecordType">
      <quanValType><xsl:value-of select="." /></quanValType>
    </xsl:for-each>
    <xsl:for-each select="gmd:valueUnit/gml:UnitDefinition">
      <quanValUnit>
        <xsl:call-template name="UnitOfMeasure" />
      </quanValUnit>
    </xsl:for-each>
    <xsl:for-each select="gmd:errorStatistic/gco:CharacterString">
      <errStat><xsl:value-of select="." /></errStat>
    </xsl:for-each>
    <xsl:for-each select="gmd:value/gco:Record">
      <quanVal><xsl:value-of select="." /></quanVal>
    </xsl:for-each>  
  </xsl:template>
  
  <!-- B.2.4.5 Scope information -->
  <!-- DQ_Scope -->
  <xsl:template name="DQ_Scope">
    <xsl:for-each select="gmd:level/gmd:MD_ScopeCode">
      <scpLvl>
        <ScopeCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_ScopeCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </ScopeCd>
      </scpLvl>
    </xsl:for-each>
    <xsl:for-each select="gmd:extent/gmd:EX_Extent">
      <scpExt>
        <xsl:call-template name="EX_Extent" />
      </scpExt>
    </xsl:for-each>
    <xsl:for-each select="gmd:levelDescription/gmd:MD_ScopeDescription">
      <scpLvlDesc>
        <xsl:call-template name="MD_ScopeDescription" />
      </scpLvlDesc>
    </xsl:for-each>  
  </xsl:template>
  
  <!-- B.2.5 Maintenance information -->

  <!-- B.2.5.1 General maintenance information -->
  <!-- MD_MaintenanceInformation -->
  <xsl:template name="MD_MaintenanceInformation">
    <xsl:for-each select="gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode">
      <maintFreq>
        <MaintFreqCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_MaintenanceFrequencyCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </MaintFreqCd>
      </maintFreq>
    </xsl:for-each>
    <xsl:for-each select="gmd:dateOfNextUpdate">
      <xsl:for-each select="gco:Date | gco:DateTime">
        <dateNext><xsl:value-of select="."/></dateNext>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="gmd:userDefinedMaintenanceFrequency/gts:TM_PeriodDuration">
      <usrDefFreq>
        <duration><xsl:value-of select="."/></duration>
      </usrDefFreq>
    </xsl:for-each>
    <xsl:for-each select="gmd:updateScope/gmd:MD_ScopeCode">
      <maintScp>
        <ScopeCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_ScopeCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue"/></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </ScopeCd>
      </maintScp>
    </xsl:for-each>
    <xsl:for-each select="gmd:updateScopeDescription/gmd:MD_ScopeDescription">
      <upScpDesc>
        <xsl:call-template name="MD_ScopeDescription"/>
      </upScpDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:maintenanceNote/gco:CharacterString">
      <maintNote><xsl:value-of select="." /></maintNote>
    </xsl:for-each>
    <xsl:for-each select="gmd:contact/gmd:CI_ResponsibleParty">
      <maintCont>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </maintCont>
    </xsl:for-each>
  </xsl:template>
  
  
  <!-- B.2.5.2 Scope description information -->
  <!-- MD_ScopeDescription -->
  <xsl:template name="MD_ScopeDescription">
    <xsl:for-each select="gmd:attributes">
      <attribSet><xsl:value-of select="@uuidref" /></attribSet>
    </xsl:for-each>
    <xsl:for-each select="gmd:features">
      <featSet><xsl:value-of select="@uuidref" /></featSet>
    </xsl:for-each>
    <xsl:for-each select="gmd:featureInstances">
      <featIntSet><xsl:value-of select="@uuidref" /></featIntSet>
    </xsl:for-each>
    <xsl:for-each select="gmd:attributeInstances">
      <attribIntSet><xsl:value-of select="@uuidref" /></attribIntSet>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gco:CharacterString">
      <datasetSet><xsl:value-of select="." /></datasetSet>
    </xsl:for-each>
    <xsl:for-each select="gmd:other/gco:CharacterString">
      <other><xsl:value-of select="." /></other>
    </xsl:for-each>
  </xsl:template>

  <!-- B.2.6 Spatial representation information (includes grid and vector representation) -->
  
  <!-- B.2.6.1 General spatial representation information -->
  <!-- MD_SpatialRepresentation -->
  <xsl:template name="MD_SpatialRepresentation">
    <xsl:variable name="spatialRepresentationInfoSubclass">
      <xsl:value-of select="name()" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$spatialRepresentationInfoSubclass = 'MD_GridSpatialRepresentation'">
        <GridSpatRep>
          <xsl:call-template name="MD_GridSpatialRepresentation" />
        </GridSpatRep>
      </xsl:when>
      <xsl:when test="$spatialRepresentationInfoSubclass = 'MD_Georectified'">
        <Georect>
          <xsl:call-template name="MD_Georectified" />
        </Georect>
      </xsl:when>
      <xsl:when test="$spatialRepresentationInfoSubclass = 'MD_Georeferenceable'">
        <Georef>
          <xsl:call-template name="MD_Georeferenceable" />
        </Georef>
      </xsl:when>
      <xsl:when test="$spatialRepresentationInfoSubclass = 'MD_VectorSpatialRepresentation'">
        <VectSpatRep>
          <xsl:call-template name="MD_VectorSpatialRepresentation" />
        </VectSpatRep>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- MD_GridSpatialRepresentation -->
  <xsl:template name="MD_GridSpatialRepresentation">
    <xsl:for-each select="gmd:numberOfDimensions/gco:Integer">
      <numDims><xsl:value-of select="."/></numDims>
    </xsl:for-each>
    <xsl:for-each select="gmd:axisDimensionProperties/gmd:MD_Dimension">
      <axisDimension>
        <xsl:call-template name="MD_Dimension" />
      </axisDimension>
    </xsl:for-each>
    <xsl:for-each select="gmd:cellGeometry/gmd:MD_CellGeometryCode">
      <cellGeo>
        <CellGeoCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_CellGeometryCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </CellGeoCd>
      </cellGeo>
    </xsl:for-each>
    <xsl:for-each select="gmd:transformationParameterAvailability/gco:Boolean">
      <tranParaAv><xsl:value-of select="." /></tranParaAv>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MD_Georectified -->
  <xsl:template name="MD_Georectified">
    <xsl:call-template name="MD_GridSpatialRepresentation"/>
    
    <xsl:for-each select="gmd:checkPointAvailability/gco:Boolean">
      <chkPtAv><xsl:value-of select="." /></chkPtAv>
    </xsl:for-each>    
    <xsl:for-each select="gmd:checkPointDescription/gco:CharacterString">
      <chkPtDesc><xsl:value-of select="." /></chkPtDesc>
    </xsl:for-each>    
    <xsl:for-each select="gmd:cornerPoints/gml:Point">
      <cornerPts>
        <xsl:call-template name="GM_Point" />
      </cornerPts>
    </xsl:for-each>
    <xsl:for-each select="gmd:centerPoint/gml:Point">
      <centerPt>
        <xsl:call-template name="GM_Point" />
      </centerPt>
    </xsl:for-each>
    <xsl:for-each select="gmd:pointInPixel/gmd:MD_PixelOrientationCode">
      <ptInPixel>
        <PixOrientCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_PixelOrientationCode">
              <xsl:with-param name="source"><xsl:value-of select="." /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </PixOrientCd>
      </ptInPixel>
    </xsl:for-each>
    
    <xsl:for-each select="gmd:transformationDimensionDescription/gco:CharacterString">
      <transDimDesc><xsl:value-of select="." /></transDimDesc>
    </xsl:for-each>
    
    <xsl:for-each select="gmd:transformationDimensionMapping/gco:CharacterString">
      <transDimMap><xsl:value-of select="." /></transDimMap>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MD_Georeferenceable -->
  <xsl:template name="MD_Georeferenceable">
    <xsl:call-template name="MD_GridSpatialRepresentation"/>

    <xsl:for-each select="gmd:controlPointAvailability/gco:Boolean">
      <ctrlPtAv><xsl:value-of select="." /></ctrlPtAv>
    </xsl:for-each>
    <xsl:for-each select="gmd:orientationParameterAvailability/gco:Boolean">
      <orieParaAv><xsl:value-of select="." /></orieParaAv>
    </xsl:for-each>
    <xsl:for-each select="gmd:orientationParameterDescription/gco:CharacterString">
      <orieParaDs><xsl:value-of select="." /></orieParaDs>
    </xsl:for-each>
    <xsl:for-each select="gmd:georeferencedParameters/gco:Record">
      <georefPars><xsl:value-of select="." /></georefPars>
    </xsl:for-each>
    <xsl:for-each select="gmd:parameterCitation/gmd:CI_Citation">
      <paraCit>
        <xsl:call-template name="CI_Citation" />
      </paraCit>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MD_VectorSpatialRepresentation -->
  <xsl:template name="MD_VectorSpatialRepresentation">
    <xsl:for-each select="gmd:topologyLevel/gmd:MD_TopologyLevelCode">
      <topLvl>
        <TopoLevCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_TopologyLevelCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </TopoLevCd>
      </topLvl>
    </xsl:for-each>
    <xsl:for-each select="gmd:geometricObjects/gmd:MD_GeometricObjects">
      <geometObjs>
        <xsl:call-template name="MD_GeometricObjects" />
      </geometObjs>
    </xsl:for-each>    
  </xsl:template>
  
  <!-- B.2.6.2 Dimension information -->
  <!-- MD_Dimension -->
  <xsl:template name="MD_Dimension">
    <xsl:for-each select="gmd:dimensionName/gmd:MD_DimensionNameTypeCode">
      <xsl:attribute name="type">
        <xsl:call-template name="MD_DimensionNameTypeCode">
          <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="gmd:dimensionSize/gco:Integer">
      <dimSize><xsl:value-of select="."/></dimSize>
    </xsl:for-each>
    <xsl:for-each select="gmd:resolution/gco:Measure">
      <dimResol>
        <xsl:call-template name="Measure" />
      </dimResol>
    </xsl:for-each>    
  </xsl:template>
  
  <!-- B.2.6.3 Geometric object information -->
  <!-- MD_GeometricObjects -->
  <xsl:template name="MD_GeometricObjects">
    <xsl:for-each select="gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode">
      <geoObjTyp>
        <GeoObjTypCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_GeometricObjectTypeCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </GeoObjTypCd>
      </geoObjTyp>
    </xsl:for-each>
    <xsl:for-each select="gmd:geometricObjectCount/gco:Integer">
      <geoObjCnt><xsl:value-of select="."/></geoObjCnt>
    </xsl:for-each>
  </xsl:template>

  <!-- B.2.7 Reference system information (includes temporal, coordinate and geographic identifiers) -->
  
  <!-- B.2.7.1 General reference system inforation -->
  <!-- MD_ReferenceSystem -->
  <xsl:template name="MD_ReferenceSystem">
    <xsl:for-each select="gmd:referenceSystemIdentifier">
      <RefSystem>
        <xsl:for-each select="gmd:RS_Identifier">
          <refSysId>
            <xsl:call-template name="RS_Identifier" />
          </refSysId>
        </xsl:for-each>
      </RefSystem>
    </xsl:for-each>    
  </xsl:template>

  
  <!-- B.2.7.2 Ellipsoid parameter information -->
  <!-- see ISO 19111 -->
  
  <!-- B.2.7.3 Identifier information -->
  <!-- MD_Identifier -->
  <xsl:template name="MD_Identifier">
    <xsl:for-each select="gmd:authority/gmd:CI_Citation">
      <identAuth>
        <xsl:call-template name="CI_Citation"/>
      </identAuth>
    </xsl:for-each>
    <xsl:for-each select="gmd:code/gco:CharacterString">
      <identCode><xsl:value-of select="."/></identCode>
    </xsl:for-each>
  </xsl:template>
  
  <!-- RS_Identifier -->
  <xsl:template name="RS_Identifier">
    <xsl:for-each select="gmd:authority/gmd:CI_Citation">
      <identAuth>
        <xsl:call-template name="CI_Citation"/>
      </identAuth>
    </xsl:for-each>
    <xsl:for-each select="gmd:code/gco:CharacterString">
      <identCode>
        <xsl:attribute name="code"><xsl:value-of select="."/></xsl:attribute>
      </identCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:code/gmx:Anchor">
      <identCode>
        <xsl:attribute name="code"><xsl:value-of select="."/></xsl:attribute>
      </identCode>
      <idCodeSpace><xsl:value-of select="@xlink:href"/></idCodeSpace>
    </xsl:for-each>
    <xsl:for-each select="gmd:codeSpace/gco:CharacterString">
      <idCodeSpace><xsl:value-of select="."/></idCodeSpace>
    </xsl:for-each>
    <xsl:for-each select="gmd:version/gco:CharacterString">
      <identVrsn><xsl:value-of select="."/></identVrsn>
    </xsl:for-each>
  </xsl:template>
  
  
  <!-- B.2.8 Content information (includes Feature catalogue and Coverage descriptions) -->

  <!-- B.2.8.1 General content information -->
  <!-- MD_ContentInformation (abstract) -->
  <xsl:template name="MD_ContentInformation">
    <xsl:variable name="subclass">
      <xsl:value-of select="local-name()" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$subclass = 'MD_FeatureCatalogueDescription'">
        <FetCatDesc>
          <xsl:call-template name="MD_FeatureCatalogueDescription" />
        </FetCatDesc>
      </xsl:when>
      <xsl:when test="$subclass = 'MD_CoverageDescription'">
        <CovDesc>
          <xsl:call-template name="MD_CoverageDescription" />
        </CovDesc>
      </xsl:when>
      <xsl:when test="$subclass = 'MI_CoverageDescription'">
        <xsl:call-template name="MD_CoverageDescription" />
      </xsl:when>
      <xsl:when test="$subclass = 'MD_ImageDescription'">
        <ImgDesc>
          <xsl:call-template name="MD_ImageDescription" />
        </ImgDesc>
      </xsl:when>
      <xsl:when test="$subclass = 'MI_ImageDescription'">
        <xsl:call-template name="MD_ImageDescription" />
      </xsl:when>
      <xsl:otherwise>
        <ERROR><xsl:value-of select="$subclass" /></ERROR>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- MD_FeatureCatalogueDescription -->
  <xsl:template name="MD_FeatureCatalogueDescription">
    <xsl:for-each select="gmd:complianceCode/gco:Boolean">
      <compCode><xsl:value-of select="." /></compCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:language[(gco:CharacterString) or (gmd:LanguageCode)]">
      <catLang>
        <xsl:for-each select="gco:CharacterString">
          <xsl:variable name="lowerValue" select="translate(., $upper, $lower)" />
          <languageCode>
            <xsl:attribute name="value">
              <xsl:apply-templates select="$languages_632">
                <xsl:with-param name="lower" select="$lowerValue" />
                <xsl:with-param name="original" select="." />
              </xsl:apply-templates>
            </xsl:attribute>
          </languageCode>
        </xsl:for-each>
        <xsl:for-each select="gmd:LanguageCode">
          <languageCode>
            <xsl:attribute name="value"><xsl:value-of select="@codeListValue" /></xsl:attribute>
          </languageCode>
        </xsl:for-each>
      </catLang>
    </xsl:for-each>
    <xsl:for-each select="gmd:includedWithDataset/gco:Boolean">
      <incWithDS><xsl:value-of select="." /></incWithDS>
    </xsl:for-each>
    <!-- do we need to deal with more than just LocalName? -->
    <xsl:for-each select="gmd:featureTypes/gco:LocalName">
      <catFetTyps>
        <genericName>
          <xsl:for-each select="@codeSpace">
            <xsl:attribute name="codeSpace"><xsl:value-of select="." /></xsl:attribute>
          </xsl:for-each>
          <xsl:value-of select="." />
        </genericName>
      </catFetTyps>
    </xsl:for-each>
    <xsl:for-each select="gmd:featureCatalogueCitation/gmd:CI_Citation">
      <catCitation>
        <xsl:call-template name="CI_Citation" />
      </catCitation>
    </xsl:for-each>    
  </xsl:template>

  <!-- MD_CoverageDescription -->
  <xsl:template name="MD_CoverageDescription">
    <xsl:for-each select="gmd:attributeDescription/gco:RecordType">
      <attDesc>
        <xsl:value-of select="." />
      </attDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:contentType/gmd:MD_CoverageContentTypeCode">
      <contentTyp>
        <ContentTypCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_CoverageContentTypeCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </ContentTypCd>
      </contentTyp>
    </xsl:for-each>
    <xsl:for-each select="gmd:dimension">
      <covDim>
        <xsl:for-each select="gmd:MD_RangeDimension">
          <RangeDim>
            <xsl:call-template name="MD_RangeDimension" />
          </RangeDim>
        </xsl:for-each>
        <xsl:for-each select="gmd:MD_Band">
          <Band>
            <xsl:call-template name="MD_Band" />
          </Band>
        </xsl:for-each>    
      </covDim>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MD_ImageDescription -->
  <xsl:template name="MD_ImageDescription">
    <xsl:call-template name="MD_CoverageDescription" />

    <xsl:for-each select="gmd:illuminationElevationAngle/gco:Real">
      <illElevAng><xsl:value-of select="." /></illElevAng>
    </xsl:for-each>
    <xsl:for-each select="gmd:illuminationAzimuthAngle/gco:Real">
      <illAziAng><xsl:value-of select="." /></illAziAng>
    </xsl:for-each>
    <xsl:for-each select="gmd:imagingCondition/gmd:MD_ImagingConditionCode">
      <imagCond>
        <ImgCondCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_ImagingConditionCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </ImgCondCd>
      </imagCond>
    </xsl:for-each>
    <xsl:for-each select="gmd:imageQualityCode/gmd:MD_Identifier">
      <imagQuCode>
        <xsl:call-template name="MD_Identifier" />
      </imagQuCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:cloudCoverPercentage/gco:Real">
      <cloudCovPer><xsl:value-of select="." /></cloudCovPer>
    </xsl:for-each>
    <xsl:for-each select="gmd:processingLevelCode/gmd:MD_Identifier">
      <prcTypCde>
        <xsl:call-template name="MD_Identifier" />
      </prcTypCde>
    </xsl:for-each>
    <xsl:for-each select="gmd:compressionGenerationQuantity/gco:Integer">
      <cmpGenQuan><xsl:value-of select="." /></cmpGenQuan>
    </xsl:for-each>
    <xsl:for-each select="gmd:triangulationIndicator/gco:Boolean">
      <trianInd><xsl:value-of select="." /></trianInd>
    </xsl:for-each>
    <xsl:for-each select="gmd:radiometricCalibrationDataAvailability/gco:Boolean">
    <radCalDatAv><xsl:value-of select="." /></radCalDatAv>
    </xsl:for-each>
    <xsl:for-each select="gmd:radiometricCalibrationDataAvailability/gco:Boolean">
    <camCalInAv><xsl:value-of select="." /></camCalInAv>
    </xsl:for-each>
    <xsl:for-each select="gmd:filmDistortionInformationAvailability/gco:Boolean">
    <filmDistInAv><xsl:value-of select="." /></filmDistInAv>
    </xsl:for-each>
    <xsl:for-each select="gmd:lensDistortionInformationAvailability/gco:Boolean">
    <lensDistInAv><xsl:value-of select="." /></lensDistInAv>
    </xsl:for-each>
  </xsl:template>

    
  <!-- B.2.8.2 Range dimension information (includes Band information) -->
  <!-- MD_RangeDimension -->
  <xsl:template name="MD_RangeDimension">
    <xsl:for-each select="gmd:sequenceIdentifier/gco:MemberName">
      <seqID>
        <xsl:call-template name="MemberName" />
      </seqID>
    </xsl:for-each>
    <xsl:for-each select="gmd:descriptor/gco:CharacterString">
      <dimDescrp><xsl:value-of select="." /></dimDescrp>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MD_Band -->
  <xsl:template name="MD_Band">
    <xsl:call-template name="MD_RangeDimension" />
    
    <xsl:for-each select="gmd:maxValue/gco:Real">
      <maxVal><xsl:value-of select="."/></maxVal>
    </xsl:for-each>
    <xsl:for-each select="gmd:minValue/gco:Real">
      <minVal><xsl:value-of select="."/></minVal>
    </xsl:for-each>
    <xsl:for-each select="gmd:units/gml:UnitDefinition">
      <valUnit>
        <xsl:call-template name="UnitOfMeasure" />
      </valUnit>
    </xsl:for-each>
    <!--
    <xsl:for-each select="gmd:units/gmd:UomLength">
      <valUnit>
        <xsl:call-template name="UnitOfMeasure" />
      </valUnit>
    </xsl:for-each>
    -->
    <xsl:for-each select="gmd:peakResponse/gco:Real">
      <pkResp><xsl:value-of select="." /></pkResp>
    </xsl:for-each>
    <xsl:for-each select="gmd:bitsPerValue/gco:Integer">
      <bitsPerVal><xsl:value-of select="." /></bitsPerVal>
    </xsl:for-each>
    <xsl:for-each select="gmd:toneGradation/gco:Integer">
      <toneGrad><xsl:value-of select="." /></toneGrad>
    </xsl:for-each>
    <xsl:for-each select="gmd:scaleFactor/gco:Real">
      <sclFac><xsl:value-of select="." /></sclFac>
    </xsl:for-each>
    <xsl:for-each select="gmd:offset/gco:Real">
      <offset><xsl:value-of select="." /></offset>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.9 Portrayal catalogue information -->
  <!-- MD_PortrayalCatalogueReference -->
  <xsl:template name="MD_PortrayalCatalogueReference">
    <xsl:for-each select="gmd:portrayalCatalogueCitation/gmd:CI_Citation">
      <portCatCit>
        <xsl:call-template name="CI_Citation" />
      </portCatCit>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.10 Distribution information -->
  
  <!-- B.2.10.1 General distribution information -->
  
  <!-- MD_Distribution -->
  <xsl:template name="MD_Distribution">
    <xsl:for-each select="gmd:distributionFormat/gmd:MD_Format">
      <distFormat>
        <xsl:call-template name="MD_Format"/>
      </distFormat>
    </xsl:for-each>
    <xsl:for-each select="gmd:distributor/gmd:MD_Distributor">
      <distributor>
        <xsl:call-template name="MD_Distributor"/>
      </distributor>
    </xsl:for-each>
    <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions">
      <distTranOps>
        <xsl:call-template name="MD_DigitalTransferOptions"/>
      </distTranOps>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.10.2 Digital transfer options information -->
  <!-- MD_DigitalTransferOptions -->
  <xsl:template name="MD_DigitalTransferOptions">
    <xsl:for-each select="gmd:unitsOfDistribution/gco:CharacterString">
      <unitsODist><xsl:value-of select="."/></unitsODist>
    </xsl:for-each>
    <xsl:for-each select="gmd:transferSize/gco:Real">
      <transSize><xsl:value-of select="."/></transSize>
    </xsl:for-each>
    <xsl:for-each select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gmx:Anchor[@xlink:href != '']">
      <xsl:if test="(@xlink:href != /gmd:MD_Metadata/distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL)">
        <onLineSrc>
          <linkage><xsl:value-of select="@xlink:href"/></linkage>
        </onLineSrc>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="gmd:onLine/gmd:CI_OnlineResource">
      <onLineSrc>
        <xsl:call-template name="CI_OnlineResource"/>
      </onLineSrc>
    </xsl:for-each>
    <xsl:for-each select="gmd:offLine/gmd:MD_Medium">
      <offLineMed>
        <xsl:call-template name="MD_Medium"/>
      </offLineMed>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.10.3 Distributor information -->
  <!-- MD_Distributor -->
  <xsl:template name="MD_Distributor">
    <xsl:for-each select="gmd:distributorContact/gmd:CI_ResponsibleParty">
      <distorCont>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </distorCont>
    </xsl:for-each>
    <xsl:for-each select="gmd:distributionOrderProcess/gmd:MD_StandardOrderProcess">
      <distorOrdPrc>
        <xsl:call-template name="MD_StandardOrderProcess"/>
      </distorOrdPrc>
    </xsl:for-each>  
    <xsl:for-each select="gmd:distributorFormat/gmd:MD_Format">
      <distorFormat>
        <xsl:call-template name="MD_Format"/>
      </distorFormat>
    </xsl:for-each>
    <xsl:for-each select="gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions">
      <distorTran>
        <xsl:call-template name="MD_DigitalTransferOptions"/>
      </distorTran>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.10.4 Format information -->
  <!-- MD_Format -->
  <xsl:template name="MD_Format">
    <xsl:for-each select="gmd:name/gco:CharacterString">
      <formatName><xsl:value-of select="."/></formatName>
    </xsl:for-each>
    <xsl:for-each select="gmd:version/gco:CharacterString">
      <formatVer><xsl:value-of select="."/></formatVer>
    </xsl:for-each>
    <xsl:for-each select="gmd:amendmentNumber/gco:CharacterString">
      <formatAmdNum><xsl:value-of select="."/></formatAmdNum>
    </xsl:for-each>
    <xsl:for-each select="gmd:specification/gco:CharacterString">
      <formatSpec><xsl:value-of select="."/></formatSpec>
    </xsl:for-each>
      <xsl:for-each select="gmd:fileDecompressionTechnique/gco:CharacterString">
    <fileDecmTech><xsl:value-of select="."/></fileDecmTech>
    </xsl:for-each>
    <xsl:for-each select="gmd:formatDistributor/gmd:MD_Distributor">
      <formatDist>
        <xsl:call-template name="MD_Distributor"/>
      </formatDist>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.10.5 Medium information -->
  <!-- MD_Medium -->
  <xsl:template name="MD_Medium">
    <xsl:for-each select="gmd:name/gmd:MD_MediumNameCode">
      <medName>
        <MedNameCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_MediumNameCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </MedNameCd>
      </medName>
    </xsl:for-each>
    <xsl:for-each select="gmd:density/gco:Real">
      <medDensity><xsl:value-of select="." /></medDensity>
    </xsl:for-each>
    <xsl:for-each select="gmd:densityUnits/gco:CharacterString">
      <medDenUnits><xsl:value-of select="." /></medDenUnits>
    </xsl:for-each>
    <xsl:for-each select="gmd:volumes/gco:Integer">
      <medVol><xsl:value-of select="." /></medVol>
    </xsl:for-each>
    <xsl:for-each select="gmd:mediumFormat/gmd:MD_MediumFormatCode">
      <medFormat>
        <MedFormCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_MediumFormatCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </MedFormCd>
      </medFormat>
    </xsl:for-each>
    <xsl:for-each select="gmd:mediumNote/gco:CharacterString">
      <medNote><xsl:value-of select="." /></medNote>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.2.10.6 Standard order process information -->
  <!-- MD_StandardOrderProcess -->  
  <xsl:template name="MD_StandardOrderProcess">
    <xsl:for-each select="gmd:fees/gco:CharacterString">
      <resFees>
        <!-- units="USD"
        <xsl:attribute name="value">
          <xsl:call-template name="MD_MediumNameCode">
          <xsl:with-param name="source"><xsl:value-of select="gmd:offLine/gmd:MD_Medium/gmd:name/gmd:MD_MediumNameCode/@codeListValue"/></xsl:with-param> 
        </xsl:call-template>
        </xsl:attribute>
        -->
        <xsl:value-of select="." />
      </resFees>
    </xsl:for-each>
    <xsl:for-each select="gmd:plannedAvailableDateTime/gco:DateTime">
      <planAvDtTm><xsl:value-of select="." /></planAvDtTm>
    </xsl:for-each>
    <xsl:for-each select="gmd:orderingInstructions/gco:CharacterString">
      <ordInstr><xsl:value-of select="." /></ordInstr>
    </xsl:for-each>
    <xsl:for-each select="gmd:turnaround/gco:CharacterString">
      <ordTurn><xsl:value-of select="." /></ordTurn>  
    </xsl:for-each>
  </xsl:template>


  <!-- B.2.11 Metadata extension information -->

  <!-- B.2.11.1 General extension information -->
  <!-- MD_MetadataExtensionInformation -->
  <xsl:template name="MD_MetadataExtensionInformation">
    <xsl:for-each select="gmd:extensionOnLineResource/gmd:CI_OnlineResource">
      <extOnRes>
        <xsl:call-template name="CI_OnlineResource" />
      </extOnRes>
    </xsl:for-each>
    <xsl:for-each select="gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation">
      <extEleInfo>
        <xsl:call-template name="MD_ExtendedElementInformation" />
      </extEleInfo>
    </xsl:for-each>
  </xsl:template>

  <!-- B.2.11.2 Extended element information -->
  <!-- MD_ExtendedElementInformation -->
  <xsl:template name="MD_ExtendedElementInformation">
    <xsl:for-each select="gmd:name/gco:CharacterString">
      <extEleName><xsl:value-of select="."/></extEleName>
    </xsl:for-each>
    <xsl:for-each select="gmd:shortName/gco:CharacterString">
      <extShortName><xsl:value-of select="."/></extShortName>
    </xsl:for-each>
    <xsl:for-each select="gmd:domainCode/gco:Integer">
      <extDomCode><xsl:value-of select="."/></extDomCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:definition/gco:CharacterString">
      <extEleDef><xsl:value-of select="."/></extEleDef>
    </xsl:for-each>
    <xsl:for-each select="gmd:obligation/gmd:MD_ObligationCode">
      <extEleOb>
        <ObCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_ObligationCode">
              <xsl:with-param name="source" select="."/>
            </xsl:call-template>
          </xsl:attribute>
        </ObCd>
      </extEleOb>
    </xsl:for-each>
    <xsl:for-each select="gmd:condition/gco:CharacterString">
      <extEleCond><xsl:value-of select="."/></extEleCond>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataType/gmd:MD_DatatypeCode">
      <eleDataType>
        <DatatypeCd>
          <xsl:attribute name="value">
            <xsl:call-template name="MD_DatatypeCode">
              <xsl:with-param name="source" select="@codeListValue"/>
            </xsl:call-template>
          </xsl:attribute>
        </DatatypeCd>
      </eleDataType>
    </xsl:for-each>
    <xsl:for-each select="gmd:maximumOccurrence/gco:CharacterString">
      <extEleMxOc><xsl:value-of select="."/></extEleMxOc>
    </xsl:for-each>
    <xsl:for-each select="gmd:domainValue/gco:CharacterString">
      <extEleDomVal><xsl:value-of select="."/></extEleDomVal>
    </xsl:for-each>
    <xsl:for-each select="gmd:parentEntity/gco:CharacterString">
      <extEleParEnt><xsl:value-of select="."/></extEleParEnt>
    </xsl:for-each>
    <xsl:for-each select="gmd:rule/gco:CharacterString">
      <extEleRule><xsl:value-of select="."/></extEleRule>
    </xsl:for-each>
    <xsl:for-each select="gmd:rationale/gco:CharacterString">
      <extEleRat><xsl:value-of select="."/></extEleRat>
    </xsl:for-each>
    <xsl:for-each select="gmd:source/gmd:CI_ResponsibleParty">
      <extEleSrc>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </extEleSrc>
    </xsl:for-each>
  </xsl:template>
    
  <!-- B.2.12 Application schema information -->
  <!-- MD_ApplicationSchemaInformation -->
  <xsl:template name="MD_ApplicationSchemaInformation">
    <xsl:for-each select="gmd:name/gmd:CI_Citation">
      <asName>
        <xsl:call-template name="CI_Citation" />
      </asName>
    </xsl:for-each>
    <xsl:for-each select="gmd:schemaLanguage/gco:CharacterString">
      <asSchLang><xsl:value-of select="."/></asSchLang>
    </xsl:for-each>
    <xsl:for-each select="gmd:constraintLanguage/gco:CharacterString">
      <asCstLang><xsl:value-of select="."/></asCstLang>
    </xsl:for-each>
    <xsl:for-each select="gmd:schemaAscii/gco:CharacterString">
      <asAscii><xsl:value-of select="."/></asAscii>
    </xsl:for-each>
    <xsl:for-each select="gmd:graphicsFile/gco:Binary">
      <asGraFile>
        <xsl:for-each select="@src">
          <xsl:attribute name="src"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
        <xsl:value-of select="."/>
      </asGraFile>
    </xsl:for-each>
    <xsl:for-each select="gmd:softwareDevelopmentFile/gco:Binary">
      <asSwDevFile>
        <xsl:for-each select="@src">
          <xsl:attribute name="src"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
        <xsl:value-of select="."/>
      </asSwDevFile>
    </xsl:for-each>
    <xsl:for-each select="gmd:softwareDevelopmentFileFormat/gco:CharacterString">
      <asSwDevFiFt><xsl:value-of select="."/></asSwDevFiFt>
    </xsl:for-each>
  </xsl:template>

  
  <!-- B.3 Data type information -->
  
  <!-- B.3.1 Extent information -->
  <!-- B.3.1.1 General extent information -->
  <!-- EX_Extent -->
  <xsl:template name="EX_Extent">
    <xsl:for-each select="gmd:description/gco:CharacterString">
      <exDesc><xsl:value-of select="."/></exDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:geographicElement">
      <geoEle>
        <xsl:call-template name="EX_GeographicExtent" />
      </geoEle>
    </xsl:for-each>
    <xsl:for-each select="gmd:temporalElement/gmd:EX_TemporalExtent">
      <tempEle>
        <TempExtent>
          <xsl:call-template name="EX_TemporalExtent" />
        </TempExtent>
      </tempEle>
    </xsl:for-each>    
    <xsl:for-each select="gmd:temporalElement/gmd:EX_SpatialTemporalExtent">
      <tempEle>
        <SpatTempEx>
          <xsl:call-template name="EX_SpatialTemporalExtent" />
        </SpatTempEx>
      </tempEle>
    </xsl:for-each>    
    <xsl:for-each select="gmd:verticalElement/gmd:EX_VerticalExtent">
      <vertEle>
        <xsl:call-template name="EX_VerticalExtent" />
      </vertEle>
    </xsl:for-each>    
  </xsl:template>
  
  <!-- B.3.1.2 Geographic extent information -->
  <!-- EX_GeographicExtent -->
  <xsl:template name="EX_GeographicExtent">
    <xsl:for-each select="gmd:EX_GeographicBoundingBox">
      <GeoBndBox>
        <xsl:call-template name="EX_GeographicBoundingBox" />
      </GeoBndBox>
    </xsl:for-each>
    <xsl:for-each select="gmd:EX_BoundingPolygon">
      <BoundPoly>
        <xsl:call-template name="EX_BoundingPolygon" />
      </BoundPoly>
    </xsl:for-each>
    <xsl:for-each select="gmd:EX_GeographicDescription">
      <GeoDesc>
        <xsl:call-template name="EX_GeographicDescription" />
      </GeoDesc>
    </xsl:for-each>
  </xsl:template>
  
  <!-- EX_BoundingPolygon -->
  <xsl:template name="EX_BoundingPolygon">
    <xsl:for-each select="gmd:extentTypeCode/gco:Boolean">
      <exTypeCode><xsl:value-of select="." /></exTypeCode>
      <!-- if we need to switch booleans to integer values:
      <xsl:choose>
        <xsl:when test="gmd:extentTypeCode = 'true'">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
      -->
    </xsl:for-each>
    <xsl:for-each select="gmd:polygon/gml:Polygon">
      <polygon>
        <xsl:call-template name="GMLidentifiers" />
        <xsl:for-each select="gml:exterior/gml:LinearRing">
          <exterior>
            <xsl:for-each select="gml:pos">
              <pos><xsl:value-of select="." /></pos>
            </xsl:for-each>
            <xsl:for-each select="gml:posList">
              <posList><xsl:value-of select="." /></posList>
            </xsl:for-each>
          </exterior>
        </xsl:for-each>
        <xsl:for-each select="gml:interior/gml:LinearRing">
          <interior>
            <xsl:for-each select="gml:pos">
              <pos><xsl:value-of select="." /></pos>
            </xsl:for-each>
            <xsl:for-each select="gml:posList">
              <posList><xsl:value-of select="." /></posList>
            </xsl:for-each>
          </interior>
        </xsl:for-each>
      </polygon>
    </xsl:for-each>
  </xsl:template>

  <!-- EX_GeographicBoundingBox -->
  <xsl:template name="EX_GeographicBoundingBox">
    <xsl:for-each select="gmd:extentTypeCode/gco:Boolean">
      <exTypeCode><xsl:value-of select="." /></exTypeCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:westBoundLongitude/gco:Decimal">
      <westBL><xsl:value-of select="." /></westBL>
    </xsl:for-each>
    <xsl:for-each select="gmd:eastBoundLongitude/gco:Decimal">
      <eastBL><xsl:value-of select="." /></eastBL>
    </xsl:for-each>
    <xsl:for-each select="gmd:southBoundLatitude/gco:Decimal">
      <southBL><xsl:value-of select="." /></southBL>
    </xsl:for-each>
    <xsl:for-each select="gmd:northBoundLatitude/gco:Decimal">
      <northBL><xsl:value-of select="." /></northBL>
    </xsl:for-each>
  </xsl:template>
  
  <!-- EX_GeographicDescription -->
  <xsl:template name="EX_GeographicDescription">
    <xsl:for-each select="gmd:extentTypeCode/gco:Boolean">
      <exTypeCode><xsl:value-of select="." /></exTypeCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:geographicIdentifier/gmd:MD_Identifier">
      <geoId>
        <xsl:call-template name="MD_Identifier" />
      </geoId>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.3.1.3 Temporal extent information -->
  <!-- EX_TemporalExtent -->
  <xsl:template name="EX_TemporalExtent">
    <xsl:for-each select="gmd:extent">
      <exTemp>
        <xsl:call-template name="TM_Primitive" />
      </exTemp>
    </xsl:for-each>
  </xsl:template>
  
  <!-- EX_SpatialTemporalExtent -->
  <xsl:template name="EX_SpatialTemporalExtent">
    <xsl:for-each select="gmd:extent">
      <exTemp>
        <xsl:call-template name="TM_Primitive" />
      </exTemp>
    </xsl:for-each>
    <xsl:for-each select="gmd:spatialExtent">
      <exSpat>
        <xsl:call-template name="EX_GeographicExtent" />
      </exSpat>
    </xsl:for-each>
  </xsl:template>  

  <!-- B.3.1.4 Vertical extent information -->
  <!-- EX_VerticalExtent -->
  <xsl:template name="EX_VerticalExtent">
    <xsl:for-each select="gmd:minimumValue/gco:Real">
      <vertMinVal><xsl:value-of select="." /></vertMinVal>
    </xsl:for-each>
    <xsl:for-each select="gmd:maximumValue/gco:Real">
      <vertMaxVal><xsl:value-of select="." /></vertMaxVal>
    </xsl:for-each>
  </xsl:template>
  

  <!-- B.3.2 Citation and responsible party information -->
  <!-- B.3.2.1 General citation information -->
  <!-- CI_Citation -->
  <xsl:template name="CI_Citation">
    <xsl:for-each select="gmd:title/gco:CharacterString">
      <resTitle><xsl:value-of select="."/></resTitle>
    </xsl:for-each>
    <xsl:for-each select="gmd:title/gmx:Anchor">
      <resTitle><xsl:value-of select="."/></resTitle>
      <xsl:if test="(local-name(../../..) != 'citation') and (@xlink:href != '')">
        <citOnlineRes xmlns="">
          <linkage><xsl:value-of select="@xlink:href"/></linkage>
        </citOnlineRes>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="gmd:alternateTitle/gco:CharacterString">
      <resAltTitle><xsl:value-of select="."/></resAltTitle>
    </xsl:for-each>
    <xsl:if test="gmd:date/gmd:CI_Date[(gmd:date/gco:Date != '') or (gmd:date/gco:DateTime != '')]">
      <date>
        <xsl:for-each select="gmd:date/gmd:CI_Date[(gmd:date/gco:Date != '') or (gmd:date/gco:DateTime != '')]">
          <xsl:call-template name="CI_Date" />
        </xsl:for-each>
      </date>
    </xsl:if>
     <xsl:for-each select="gmd:edition/gco:CharacterString">
      <resEd><xsl:value-of select="."/></resEd>
    </xsl:for-each>
    <xsl:for-each select="gmd:editionDate">
      <xsl:for-each select="gco:Date">
        <resEdDate><xsl:value-of select="translate(.,'-','')" /></resEdDate>
      </xsl:for-each>
      <xsl:for-each select="gco:DateTime">
        <resEdDate><xsl:value-of select="translate(substring-before(.,'T'),'-','')" /></resEdDate>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="gmd:identifier/gmd:MD_Identifier">
      <citId>
        <xsl:call-template name="MD_Identifier"/>
      </citId>
    </xsl:for-each>
    <xsl:for-each select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
      <citRespParty>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/> 
        </xsl:call-template>
      </citRespParty>
    </xsl:for-each>
    <xsl:for-each select="gmd:presentationForm/gmd:CI_PresentationFormCode">
      <presForm>
        <PresFormCd>
          <xsl:attribute name="value">
            <xsl:call-template name="CI_PresentationFormCode">
              <xsl:with-param name="source" select="@codeListValue"/>
            </xsl:call-template>
          </xsl:attribute>
        </PresFormCd>
      </presForm>
    </xsl:for-each>
    <xsl:for-each select="gmd:series/gmd:CI_Series">
      <datasetSeries>
        <xsl:call-template name="CI_Series" />
      </datasetSeries>
    </xsl:for-each>
    <xsl:for-each select="gmd:otherCitationDetails/gco:CharacterString">
      <otherCitDet><xsl:value-of select="." /></otherCitDet>
    </xsl:for-each>
    <xsl:for-each select="gmd:collectiveTitle/gco:CharacterString">
      <collTitle><xsl:value-of select="." /></collTitle>
    </xsl:for-each>
    <xsl:for-each select="gmd:ISBN/gco:CharacterString">
      <isbn><xsl:value-of select="."/></isbn>
    </xsl:for-each>
    <xsl:for-each select="gmd:ISSN/gco:CharacterString">
      <issn><xsl:value-of select="."/></issn>
    </xsl:for-each>
  </xsl:template>
  
  <!-- CI_ResponsibleParty -->
  <xsl:template name="CI_ResponsibleParty">
    <xsl:param name="role"/>
    
    <xsl:for-each select="gmd:individualName/gco:CharacterString">
    <rpIndName><xsl:value-of select="."/></rpIndName>
    </xsl:for-each>
    <xsl:for-each select="gmd:organisationName/gco:CharacterString">
    <rpOrgName><xsl:value-of select="."/></rpOrgName>
    </xsl:for-each>
    <xsl:for-each select="gmd:positionName/gco:CharacterString">
      <rpPosName><xsl:value-of select="."/></rpPosName>
    </xsl:for-each>
    <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact">
      <rpCntInfo>
        <xsl:call-template name="CI_Contact" />
      </rpCntInfo>
    </xsl:for-each>
    <xsl:if test="($role != '')">
      <role>
        <RoleCd>
          <xsl:attribute name="value">
            <xsl:call-template name="CI_RoleCode">
              <xsl:with-param name="source" select="$role"/>
            </xsl:call-template>
          </xsl:attribute>
        </RoleCd>
      </role>
    </xsl:if>
  </xsl:template>
  
  <!-- B.3.2.2 Address information -->
  <!-- CI_Address -->
  <xsl:template name="CI_Address">
    <!-- addressType attribute
      <xsl:for-each select="gmd:deliveryPoint/gco:CharacterString">
        <delPoint><xsl:value-of select="."/></delPoint>
      </xsl:for-each>
    -->
    <xsl:for-each select="gmd:deliveryPoint/gco:CharacterString">
      <delPoint><xsl:value-of select="."/></delPoint>
    </xsl:for-each>
    <xsl:for-each select="gmd:city/gco:CharacterString">
      <city><xsl:value-of select="."/></city>
    </xsl:for-each>
    <xsl:for-each select="gmd:administrativeArea/gco:CharacterString">
      <adminArea><xsl:value-of select="."/></adminArea>
    </xsl:for-each>
    <xsl:for-each select="gmd:postalCode/gco:CharacterString">
      <postCode><xsl:value-of select="."/></postCode>
    </xsl:for-each>
    <xsl:for-each select="gmd:country/gco:CharacterString">
      <xsl:variable name="upperValue" select="translate(., $lower, $upper)" />
      <xsl:variable name="lowerValue" select="translate(., $upper, $lower)" />
      <country>
        <xsl:apply-templates select="$countries_3166">
          <xsl:with-param name="upper" select="$upperValue" />
          <xsl:with-param name="lower" select="$lowerValue" />
          <xsl:with-param name="original" select="." />
        </xsl:apply-templates>
      </country>
    </xsl:for-each>
    <xsl:for-each select="gmd:country/gmd:Country">
      <country><xsl:value-of select="@codeListValue"/></country>
    </xsl:for-each>
    <xsl:for-each select="gmd:electronicMailAddress/gco:CharacterString">
      <eMailAdd><xsl:value-of select="."/></eMailAdd>
    </xsl:for-each>
  </xsl:template>  
    
  <!-- B.3.2.3 Contact information -->
  <!-- CI_Contact -->
  <xsl:template name="CI_Contact">
    <xsl:for-each select="gmd:phone/gmd:CI_Telephone">
      <cntPhone>
        <xsl:call-template name="CI_Telephone" />
      </cntPhone>
    </xsl:for-each>
    <xsl:for-each select="gmd:address/gmd:CI_Address">
      <cntAddress>
        <xsl:call-template name="CI_Address" />
      </cntAddress>
    </xsl:for-each>
    <xsl:for-each select="gmd:onlineResource/gmd:CI_OnlineResource">
      <cntOnlineRes>
        <xsl:call-template name="CI_OnlineResource" />
      </cntOnlineRes>
    </xsl:for-each>
    <xsl:for-each select="gmd:hoursOfService/gco:CharacterString">
      <cntHours><xsl:value-of select="."/></cntHours>
    </xsl:for-each>
    <xsl:for-each select="gmd:contactInstructions/gco:CharacterString">
      <cntInstr><xsl:value-of select="."/></cntInstr>
    </xsl:for-each>
  </xsl:template>

  <!-- B.3.2.4 Date information -->
  <!-- CI_Date -->
  <xsl:template name="CI_Date">
    <xsl:variable name="date">
      <xsl:value-of select="gmd:date/gco:Date | gmd:date/gco:DateTime"/>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:value-of select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$type = 'publication'">
        <pubDate><xsl:value-of select="$date" /></pubDate>
      </xsl:when>
      <xsl:when test="$type = 'creation'">
        <createDate><xsl:value-of select="$date" /></createDate>
      </xsl:when>
      <xsl:when test="$type = 'revision'">
        <reviseDate><xsl:value-of select="$date" /></reviseDate>
      </xsl:when>
      <xsl:when test="$type = 'notAvailable'">
        <notavailDate><xsl:value-of select="$date" /></notavailDate>
      </xsl:when>
      <xsl:when test="$type = 'adopted'">
        <adoptDate><xsl:value-of select="$date" /></adoptDate>
      </xsl:when>
      <xsl:when test="$type = 'inForce'">
        <inforceDate><xsl:value-of select="$date" /></inforceDate>
      </xsl:when>
      <xsl:when test="$type = 'deprecated'">
        <deprecDate><xsl:value-of select="$date" /></deprecDate>
      </xsl:when>
      <xsl:when test="$type = 'superseded'">
        <supersDate><xsl:value-of select="$date" /></supersDate>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- B.3.2.5 OnLine resource information -->
  <!-- CI_OnlineResource -->
  <xsl:template name="CI_OnlineResource">
    <xsl:for-each select="gmd:linkage/gmd:URL">
      <linkage><xsl:value-of select="."/></linkage>
    </xsl:for-each>
    <xsl:for-each select="gmd:protocol/gco:CharacterString">
      <protocol><xsl:value-of select="."/></protocol>
    </xsl:for-each>
    <xsl:for-each select="gmd:applicationProfile/gco:CharacterString">
      <appProfile><xsl:value-of select="."/></appProfile>
    </xsl:for-each>
    <xsl:for-each select="gmd:name/gco:CharacterString">
      <orName><xsl:value-of select="."/></orName>
    </xsl:for-each>
    <xsl:for-each select="gmd:description/gco:CharacterString">
      <orDesc><xsl:value-of select="."/></orDesc>
    </xsl:for-each>
    <xsl:for-each select="gmd:function/gmd:CI_OnLineFunctionCode">
      <orFunct>
        <OnFunctCd>
          <xsl:attribute name="value">
            <xsl:call-template name="CI_OnLineFunctionCode">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </OnFunctCd>
      </orFunct>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.3.2.6 Series information -->
  <!-- CI_Series -->
  <xsl:template name="CI_Series">
    <xsl:for-each select="gmd:name/gco:CharacterString">
      <seriesName><xsl:value-of select="."/></seriesName>
    </xsl:for-each>
    <xsl:for-each select="gmd:issueIdentification/gco:CharacterString">
      <issId><xsl:value-of select="."/></issId>
    </xsl:for-each>
    <xsl:for-each select="gmd:page/gco:CharacterString">
      <artPage><xsl:value-of select="."/></artPage>
    </xsl:for-each>
  </xsl:template>
  
  <!-- B.3.2.7 Telephone information -->
  <!-- CI_Telephone -->
  <xsl:template name="CI_Telephone">
    <!-- tddtty attribute
      <xsl:for-each select="gmd:deliveryPoint/gco:CharacterString">
        <delPoint><xsl:value-of select="."/></delPoint>
      </xsl:for-each>
    -->
    <xsl:for-each select="gmd:voice/gco:CharacterString">
      <voiceNum><xsl:value-of select="."/></voiceNum>
    </xsl:for-each>
    <xsl:for-each select="gmd:facsimile/gco:CharacterString">
      <faxNum><xsl:value-of select="."/></faxNum>
    </xsl:for-each>
  </xsl:template>


  <!-- B.4.3 Measure -->
  <xsl:template name="Measure">
    <value>
      <xsl:attribute name="uom"><xsl:value-of select="@uom" /></xsl:attribute>
      <xsl:value-of select="." />
    </value>    
  </xsl:template>

  <!-- B.4.3 UomLength -->
  <xsl:template name="UnitOfMeasure">
    <UOM>
      <xsl:call-template name="GMLidentifiers" />
      <xsl:for-each select="gml:remarks">
        <gmlRemarks><xsl:value-of select="."/></gmlRemarks>
      </xsl:for-each>
      <xsl:for-each select="gml:quantityType">
        <unitQuanType><xsl:value-of select="."/></unitQuanType>
      </xsl:for-each>
      <xsl:for-each select="gml:quantityTypeReference/@xlink:href">
        <unitQuanRef>
          <xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
        </unitQuanRef>
      </xsl:for-each>
      <xsl:for-each select="gml:catalogSymbol">
        <unitSymbol>
          <xsl:for-each select="@codeSpace">
            <xsl:attribute name="codeSpace"><xsl:value-of select="." /></xsl:attribute>
          </xsl:for-each>
          <xsl:value-of select="." />
        </unitSymbol>
      </xsl:for-each>
    </UOM>
  </xsl:template>

  <!-- B.4.5 TM_Primitive -->
  <xsl:template name="TM_Primitive">
    <xsl:for-each select="gml:TimePeriod">
      <TM_Period>
        <xsl:call-template name="GMLidentifiers" />
        <xsl:for-each select="gml:beginPosition">
          <tmBegin>
            <xsl:for-each select="@indeterminatePosition">
              <xsl:attribute name="date"><xsl:value-of select="." /></xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="."/>
          </tmBegin>
        </xsl:for-each>
        <xsl:for-each select="gml:endPosition">
          <tmEnd>
            <xsl:for-each select="@indeterminatePosition">
              <xsl:attribute name="date"><xsl:value-of select="." /></xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="."/>
          </tmEnd>
        </xsl:for-each>
      </TM_Period>
    </xsl:for-each>

    <xsl:for-each select="gml:TimeInstant">
      <TM_Instant>
        <xsl:call-template name="GMLidentifiers" />
        <xsl:for-each select="gml:timePosition">
          <tmPosition>
            <xsl:for-each select="@indeterminatePosition">
              <xsl:attribute name="date"><xsl:value-of select="." /></xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="."/>
          </tmPosition>
        </xsl:for-each>
      </TM_Instant>
    </xsl:for-each>
  </xsl:template>
  
  <!-- MemberName -->
  <xsl:template name="MemberName">
    <xsl:for-each select="gco:aName/gco:CharacterString">
      <aName><xsl:value-of select="." /></aName>
    </xsl:for-each>
    <xsl:for-each select="gco:attributeType/gco:TypeName">
      <attributeType>
        <xsl:call-template name="TypeName" />
      </attributeType>
    </xsl:for-each>
  </xsl:template>

  <!-- TypeName -->
  <xsl:template name="TypeName">
    <xsl:for-each select="gco:aName/gco:CharacterString">
      <aName><xsl:value-of select="." /></aName>
    </xsl:for-each>
  </xsl:template>

  
  <!-- GML elements providing basic identifiers for all types -->
  <xsl:template name="GMLidentifiers">
    <xsl:for-each select="@gml:id">
      <xsl:attribute name="gmlID"><xsl:value-of select="." /></xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="gml:description">
      <gmlDesc><xsl:value-of select="." /></gmlDesc>
    </xsl:for-each>
    <xsl:for-each select="gml:descriptionReference/@xlink:href">
      <gmlDescRef>
        <xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
      </gmlDescRef>
    </xsl:for-each>
    <xsl:for-each select="gml:identifier">
      <gmlIdent>
        <xsl:for-each select="@codeSpace">
          <xsl:attribute name="codeSpace"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
        <xsl:value-of select="." />
      </gmlIdent>
    </xsl:for-each>
    <xsl:for-each select="gml:name">
      <gmlName>
        <xsl:for-each select="@codeSpace">
          <xsl:attribute name="codeSpace"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
        <xsl:value-of select="." />
      </gmlName>
    </xsl:for-each>
  </xsl:template>

  
  <!-- ISO 19119 below -->

  <!-- SV_ServiceSpecitication -->
  <!-- SV_Interface -->
  <!-- SV_Operation -->
  <!-- SV_OperationChainMetadata -->
  
  <!-- SV_ServiceIdentification -->
  <xsl:template name="SV_ServiceIdentification">
    <xsl:call-template name="MD_Identification" />

    <!-- do we need to deal with more than just LocalName? -->
    <xsl:for-each select="srv:serviceType/gco:LocalName">
      <svType>
        <genericName>
          <xsl:for-each select="@codeSpace">
            <xsl:attribute name="codeSpace"><xsl:value-of select="."/></xsl:attribute>
          </xsl:for-each>
          <xsl:value-of select="."/>
        </genericName>
      </svType>
    </xsl:for-each>
    <xsl:for-each select="srv:serviceTypeVersion/gco:CharacterString">
      <svTypeVer><xsl:value-of select="."/></svTypeVer>
    </xsl:for-each>
    <xsl:for-each select="srv:accessProperties/gmd:MD_StandardOrderProcess">
      <svAccProps>
        <xsl:call-template name="MD_StandardOrderProcess" />
      </svAccProps>
    </xsl:for-each>
    <xsl:for-each select="srv:extent/gmd:EX_Extent">
      <dataExt>
        <xsl:call-template name="EX_Extent" />
      </dataExt>
    </xsl:for-each>
    <xsl:for-each select="srv:coupledResource/srv:SV_CoupledResource">
      <svCouplRes>
        <xsl:call-template name="SV_CoupledResource" />
      </svCouplRes>
    </xsl:for-each>
    <xsl:for-each select="srv:couplingType/srv:SV_CouplingType">
      <svCouplType>
        <CouplTypCd>
          <xsl:attribute name="value">
            <xsl:call-template name="SV_CouplingType">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </CouplTypCd>
      </svCouplType>
    </xsl:for-each>
    <xsl:for-each select="srv:containsOperations/srv:SV_OperationMetadata">
      <svOper>
        <xsl:call-template name="SV_OperationMetadata" />
      </svOper>
    </xsl:for-each>
    <xsl:for-each select="srv:operatesOn/gmd:MD_DataIdentification">
      <svOperOn>
        <xsl:call-template name="MD_DataIdentification" />
      </svOperOn>
    </xsl:for-each>
  </xsl:template>

  <!-- SV_CoupledResource -->
  <xsl:template name="SV_CoupledResource">
    <xsl:for-each select="srv:operationName/gco:CharacterString">
      <svOpName><xsl:value-of select="."/></svOpName>
    </xsl:for-each>
    <xsl:for-each select="srv:identifier/gco:CharacterString">
      <svResCitId>
        <identCode><xsl:value-of select="."/></identCode>
      </svResCitId>
    </xsl:for-each>
  </xsl:template>

  <!-- SV_OperationMetadata -->
  <xsl:template name="SV_OperationMetadata">
    <xsl:for-each select="srv:operationName/gco:CharacterString">
      <svOpName><xsl:value-of select="."/></svOpName>
    </xsl:for-each>
    <xsl:for-each select="srv:DCP/srv:DCPList">
      <svDCP>
        <DCPListCd>
          <xsl:attribute name="value">
            <xsl:call-template name="DCPList">
              <xsl:with-param name="source"><xsl:value-of select="@codeListValue" /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </DCPListCd>
      </svDCP>
    </xsl:for-each>
    <xsl:for-each select="srv:operationDescription/gco:CharacterString">
      <svDesc><xsl:value-of select="."/></svDesc>
    </xsl:for-each>
    <xsl:for-each select="srv:invocationName/gco:CharacterString">
      <svInvocName><xsl:value-of select="."/></svInvocName>
    </xsl:for-each>
    <xsl:for-each select="srv:parameters/srv:SV_Parameter">
      <svParams>
        <xsl:call-template name="SV_Parameter" />
      </svParams>
    </xsl:for-each>
    <xsl:for-each select="srv:connectPoint/gmd:CI_OnlineResource">
      <svConPt>
        <xsl:call-template name="CI_OnlineResource" />
      </svConPt>
    </xsl:for-each>
    <xsl:for-each select="srv:dependsOn/srv:SV_OperationMetadata">
      <svOper>
        <xsl:call-template name="SV_OperationMetadata" />
      </svOper>
    </xsl:for-each>
  </xsl:template>

  <!-- SV_Parameter -->
  <xsl:template name="SV_Parameter">
    <xsl:for-each select="srv:name/gco:MemberName">
      <svParName>
        <xsl:call-template name="MemberName" />
      </svParName>
    </xsl:for-each>
    <xsl:for-each select="srv:direction/srv:SV_ParameterDirection">
      <svParDir>
        <ParamDirCd>
          <xsl:attribute name="value">
            <xsl:call-template name="SV_ParameterDirection">
              <xsl:with-param name="source"><xsl:value-of select="." /></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </ParamDirCd>
      </svParDir>
    </xsl:for-each>
    <xsl:for-each select="srv:description/gco:CharacterString">
      <svDesc><xsl:value-of select="."/></svDesc>
    </xsl:for-each>
    <xsl:for-each select="srv:optionality/gco:CharacterString">
      <svParOpt><xsl:value-of select="."/></svParOpt>
    </xsl:for-each>
    <xsl:for-each select="srv:repeatability/gco:Boolean">
      <svRepeat><xsl:value-of select="."/></svRepeat>
    </xsl:for-each>
    <xsl:for-each select="srv:valueType">
      <svValType>
        <xsl:for-each select="gco:TypeName">
          <xsl:call-template name="TypeName" />
        </xsl:for-each>
      </svValType>
    </xsl:for-each>
  </xsl:template>

  

  <!-- DOMAIN Conversions below -->

  <!-- B.5.2 CI_DateTypeCode -->
  <xsl:template name="CI_DateTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'creation'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'publication'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'revision'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'notAvailable'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'inForce'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'adopted'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'deprecated'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'superseded'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <!-- B.5.3 CI_OnLineFunctionCode -->
  <xsl:template name="CI_OnLineFunctionCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'download'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'information'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'offlineAccess'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'order'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'search'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'upload'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'webService'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'emailService'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'browsing'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fileAccess'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'webMapService'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- B.5.4 CI_PresentationFormCode -->
  <xsl:template name="CI_PresentationFormCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'documentDigital'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'documentHardcopy'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'imageDigital'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'imageHardcopy'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mapDigital'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mapHardcopy'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'modelDigital'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'modelHardcopy'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'profileDigital'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'profileHardcopy'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tableDigital'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tableHardcopy'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'videoDigital'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'videoHardcopy'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'audioDigital'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'audioHardcopy'">
        <xsl:text>016</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'multimediaDigital'">
        <xsl:text>017</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'multimediaHardcopy'">
        <xsl:text>018</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'diagramDigital'">
        <xsl:text>019</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'diagramHardcopy'">
        <xsl:text>020</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.5 CI_RoleCode -->
  <xsl:template name="CI_RoleCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'resourceProvider'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'custodian'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'owner'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'user'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'distributor'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'originator'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'pointOfContact'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'principalInvestigator'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'processor'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'publisher'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'author'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'collaborator'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'editor'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mediator'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'rightsHolder'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.6 DQ_EvaluationMethodTypeCode -->
  <xsl:template name="DQ_EvaluationMethodTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'directInternal'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'directExternal'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'indirect'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.7 DS_AssociationTypeCode -->
  <xsl:template name="DS_AssociationTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'crossReference'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'largerWorkCitation'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'partOfSeamlessDatabase'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'source'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'stereoMate'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'isComposedOf'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.8 DS_InitiativeTypeCode -->
  <xsl:template name="DS_InitiativeTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'campaign'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'collection'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'exercise'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'experiment'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'investigation'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mission'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sensor'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'operation'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'platform'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'process'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'program'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'project'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'study'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'task'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'trial'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.9 MD_CellGeometryCode -->
  <xsl:template name="MD_CellGeometryCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'point'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'area'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'voxel'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.10 MD_CharacterSetCode -->
  <xsl:template name="MD_CharacterSetCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'ucs2'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'ucs4'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'utf7'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'utf8'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'utf16'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part1'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part2'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part3'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part4'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part5'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part6'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part7'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part8'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part9'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part10'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part11'">
        <xsl:text>016</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part13'">
        <xsl:text>018</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part14'">
        <xsl:text>019</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part15'">
        <xsl:text>020</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8859part16'">
        <xsl:text>021</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'jis'">
        <xsl:text>022</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'shiftJIS'">
        <xsl:text>023</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'eucJP'">
        <xsl:text>024</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'usAscii'">
        <xsl:text>025</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'ebcdic'">
        <xsl:text>026</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'eucKR'">
        <xsl:text>027</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'big5'">
        <xsl:text>028</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'GB2312'">
        <xsl:text>029</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- B.5.11 MD_ClassificationCode -->
  <xsl:template name="MD_ClassificationCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'unclassified'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'restricted'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'confidential'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'secret'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'topSecret'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sensitive'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'forOfficialUseOnly'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- B.5.12 MD_CoverageContentTypeCode -->
  <xsl:template name="MD_CoverageContentTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'image'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'thematicClassification'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'physicalMeasurement'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- B.5.13 MD_DatatypeCode -->
  <xsl:template name="MD_DatatypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'class'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'codelist'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'enumeration'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'codelistElement'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'abstractClass'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'aggregateClass'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'specifiedClass'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'datatypeClass'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'interfaceClass'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'unionClass'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'metaClass'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'typeClass'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'characterString'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'integer'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'association'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.14 MD_DimensionNameTypeCode -->
  <xsl:template name="MD_DimensionNameTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'row'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'column'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'vertical'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'track'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'crossTrack'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'line'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sample'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'time'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.15 MD_GeometricObjectTypeCode -->
  <xsl:template name="MD_GeometricObjectTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'complex'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'composite'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'curve'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'point'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'solid'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'surface'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.16 MD_ImagingConditionCode -->
  <xsl:template name="MD_ImagingConditionCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'blurredImage'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'cloud'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'degradingobliquity'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fog'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'heavySmokeOrDust'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'night'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'rain'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'semiDarkness'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'shadow'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'snow'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'terrainMasking'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.17 MD_KeywordTypeCode -->
  <!-- TODO -->

  <!-- B.5.18 MD_MaintenanceFrequencyCode -->
  <xsl:template name="MD_MaintenanceFrequencyCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'continual'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'daily'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'weekly'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fortnightly'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'monthly'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'quarterly'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'biannually'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'annually'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'asNeeded'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'irregular'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'notPlanned'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'unknown'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'semimonthly'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.19 MD_MediumFormatCode -->
  <xsl:template name="MD_MediumFormatCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'cpio'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tar'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'highSierra'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'iso9660'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'iso9660RockRidge'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'iso9660AppleHFS'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'UDF'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.20 MD_MediumNameCode -->
  <xsl:template name="MD_MediumNameCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'cdRom'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dvd'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dvdRom'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '3halfInchFloppy'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '5quarterInchFloppy'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '7trackTape'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '9trackTape'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '3480Cartridge'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '3490Cartridge'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '3580Cartridge'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '4mmCartridgeTape'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '8mmCartridgeTape'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = '1quarterInchCartridgeTape'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'digitalLinearTape'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'onLine'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'satellite'">
        <xsl:text>016</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'telephoneLink'">
        <xsl:text>017</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopy'">
        <xsl:text>018</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyDiazoPolyester08'">
        <xsl:text>019</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyCardMicrofilm'">
        <xsl:text>020</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyMicrofilm240'">
        <xsl:text>021</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyMicrofilm35'">
        <xsl:text>022</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyMicrofilm70'">
        <xsl:text>023</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyMicrofilmGeneral'">
        <xsl:text>024</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyMicrofilmMicrofiche'">
        <xsl:text>025</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyNegativePhoto'">
        <xsl:text>026</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyPaper'">
        <xsl:text>027</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyDiazo'">
        <xsl:text>028</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyPhoto'">
        <xsl:text>029</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardcopyTracedPaper'">
        <xsl:text>030</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'hardDisk'">
        <xsl:text>031</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'USBFlashDrive'">
        <xsl:text>032</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.21 MD_ObligationCode -->
  <xsl:template name="MD_ObligationCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'mandatory'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'optional'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'conditional'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.22 MD_PixelOrientationCode -->
  <xsl:template name="MD_PixelOrientationCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'center'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'lowerLeft'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'lowerRight'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'upperRight'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'upperLeft'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.23 MD_ProgressCode -->
  <xsl:template name="MD_ProgressCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'completed'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'historicalArchive'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'obsolete'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'onGoing'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'planned'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'required'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'underDevelopment'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'proposed'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.24 MD_RestrictionCode -->
  <xsl:template name="MD_RestrictionCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'copyright'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'patent'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'patentPending'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'trademark'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'license'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'intellectualPropertyRights'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'restricted'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'otherRestrictions'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'licenseUnrestricted'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'licenseEndUser'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'licenseDistributor'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'privacy'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'statutory'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'confidential'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sensitivity'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.25 MD_ScopeCode -->
  <xsl:template name="MD_ScopeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'attribute'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'attributeType'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'collectionHardware'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'collectionSession'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dataset'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'series'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'nonGeographicDataset'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dimensionGroup'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'feature'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'featureType'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'propertyType'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fieldSession'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'software'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'service'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'model'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tile'">
        <xsl:text>016</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'initiative'">
        <xsl:text>017</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'stereomate'">
        <xsl:text>018</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sensor'">
        <xsl:text>019</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'platformSeries'">
        <xsl:text>020</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sensorSeries'">
        <xsl:text>021</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'productionSeries'">
        <xsl:text>022</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'transferAggregate'">
        <xsl:text>023</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'otherAggregate'">
        <xsl:text>024</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.26 MD_SpatialRepresentationTypeCode -->
  <xsl:template name="MD_SpatialRepresentationTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'vector'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'grid'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'textTable'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tin'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'stereoModel'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'video'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.27 MD_TopicCategoryCode -->
  <xsl:template name="MD_TopicCategoryCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'farming'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'biota'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'boundaries'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'climatologyMeteorologyAtmosphere'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'economy'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'elevation'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'environment'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'geoscientificInformation'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'health'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'imageryBaseMapsEarthCover'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'intelligenceMilitary'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'inlandWaters'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'location'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'oceans'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'planningCadastre'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'society'">
        <xsl:text>016</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'structure'">
        <xsl:text>017</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'transportation'">
        <xsl:text>018</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'utilitiesCommunication'">
        <xsl:text>019</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- B.5.28 MD_TopologyLevelCode -->
  <xsl:template name="MD_TopologyLevelCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'geometryOnly'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'topology1D'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'planarGraph'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fullPlanarGraph'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'surfaceGraph'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fullSurfaceGraph'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'topology3D'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'fullTopology3D'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'abstract'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ISO 19119 SV_CouplingType code -->
  <xsl:template name="SV_CouplingType">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'loose'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mixed'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tight'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ISO 19119 DCP code -->
  <xsl:template name="DCPList">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'XML'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'CORBA'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'JAVA'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'COM'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'SQL'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'WebServices'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ISO 19119 SV_ParameterDirection code -->
  <xsl:template name="SV_ParameterDirection">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'in'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'out'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'in/out'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="fileFormatCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'bil'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'bmp'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'bsq'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'bzip2'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'cdr'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'cgm'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'cover'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'csv'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dbf'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dgn'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'doc'">
        <xsl:text>011</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dwg'">
        <xsl:text>012</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'dxf'">
        <xsl:text>013</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'e00'">
        <xsl:text>014</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'ecw'">
        <xsl:text>015</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'eps'">
        <xsl:text>016</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'ers'">
        <xsl:text>017</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'gdb'">
        <xsl:text>018</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'geotiff'">
        <xsl:text>019</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'gif'">
        <xsl:text>020</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'gml'">
        <xsl:text>021</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'grid'">
        <xsl:text>022</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'gzip'">
        <xsl:text>023</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'html'">
        <xsl:text>024</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'jpg'">
        <xsl:text>025</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mdb'">
        <xsl:text>026</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'mif'">
        <xsl:text>027</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'pbm'">
        <xsl:text>028</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'pdf'">
        <xsl:text>029</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'png'">
        <xsl:text>030</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'ps'">
        <xsl:text>031</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'rtf'">
        <xsl:text>032</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sdc'">
        <xsl:text>033</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'shp'">
        <xsl:text>034</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'sid'">
        <xsl:text>035</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'svg'">
        <xsl:text>036</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tab'">
        <xsl:text>037</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tar'">
        <xsl:text>038</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'tiff'">
        <xsl:text>039</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'txt'">
        <xsl:text>040</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'xhtml'">
        <xsl:text>041</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'xls'">
        <xsl:text>042</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'xml'">
        <xsl:text>043</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'xwd'">
        <xsl:text>044</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'zip'">
        <xsl:text>045</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'wpd'">
        <xsl:text>046</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Esri Geoportal Content Type Code -->
  <xsl:template name="contentTypeCode">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'Live Data and Maps'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Downloadable Data'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Offline Data'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Static Map Images'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Other Documents'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Applications'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Geographic Services'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Clearinghouses'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Map Files'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'Geographic Activities'">
        <xsl:text>010</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Esri Data Quality Element Type -->
  <xsl:template name="DQ_ElementType">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'DQ_Completeness'">
        <xsl:text>DQComplete</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_CompletenessCommission'">
        <xsl:text>DQCompComm</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_CompletenessOmission'">
        <xsl:text>DQCompOm</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_ConceptualConsistency'">
        <xsl:text>DQConcConsis</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_DomainConsistency'">
        <xsl:text>DQDomConsis</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_FormatConsistency'">
        <xsl:text>DQFormConsis</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_TopologicalConsistency'">
        <xsl:text>DQTopConsis</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_PositionalAccuracy'">
        <xsl:text>DQPosAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_AbsoluteExternalPositionalAccuracy'">
        <xsl:text>DQAbsExtPosAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_GriddedDataPositionalAccuracy'">
        <xsl:text>DQGridDataPosAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_RelativeInternalPositionalAccuracy'">
        <xsl:text>DQRelIntPosAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_TemporalAccuracy'">
        <xsl:text>DQTempAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_ThematicAccuracy'">
        <xsl:text>DQThemAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_ThematicClassificationCorrectness'">
        <xsl:text>DQThemClassCor</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_NonQuantitativeAttributeAccuracy'">
        <xsl:text>DQNonQuanAttAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_QuantitativeAttributeAccuracy'">
        <xsl:text>DQQuanAttAcc</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_AccuracyOfATimeMeasurement'">
        <xsl:text>DQAccTimeMeas</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_TemporalConsistency'">
        <xsl:text>DQTempConsis</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'DQ_TemporalValidity'">
        <xsl:text>DQTempValid</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'QeUsability'">
        <xsl:text>QeUsability</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  

  <!-- INSPIRE PublicAccessLimitsCode -->
  <xsl:template name="LimitationsOnPublicAccess">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'noLimitations'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1a'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1b'">
        <xsl:text>003</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1c'">
        <xsl:text>004</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1d'">
        <xsl:text>005</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1e'">
        <xsl:text>006</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1f'">
        <xsl:text>007</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1g'">
        <xsl:text>008</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'INSPIRE_Directive_Article13_1h'">
        <xsl:text>009</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- INSPIRE PublicAccessLimitsCode -->
  <xsl:template name="ConditionsApplyingToAccessAndUse">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'noConditionsApply'">
        <xsl:text>001</xsl:text>
      </xsl:when>
      <xsl:when test="$source = 'conditionsUnknown'">
        <xsl:text>002</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- GML TEMPLATES START HERE -->
  <xsl:template name="GM_Point">
    <xsl:for-each select="@gml:id">
      <xsl:attribute name="gmlID">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="gml:description">
      <gmlDesc><xsl:value-of select="." /></gmlDesc>
    </xsl:for-each>
    <xsl:for-each select="gml:descriptionReference/@xlink:href">
      <gmlDescRef><xsl:value-of select="." /></gmlDescRef>
    </xsl:for-each>
    <xsl:for-each select="gml:identifier">
      <gmlIdent>
        <xsl:attribute name="codeSpace">
          <xsl:value-of select="@codeSpace" />
        </xsl:attribute>
        <xsl:value-of select="." />
      </gmlIdent>
    </xsl:for-each>
    <xsl:for-each select="gml:name">
      <gmlName>
        <xsl:attribute name="codeSpace">
          <xsl:value-of select="@codeSpace" />
        </xsl:attribute>
        <xsl:value-of select="." />
      </gmlName>
    </xsl:for-each>
    <xsl:for-each select="gml:pos">
      <pos><xsl:value-of select="." /></pos>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="countryCodes">
    <xsl:param name="upper" />
    <xsl:param name="lower" />
    <xsl:param name="original" />
    <xsl:variable name="name">
      <xsl:for-each select="key('ctryName',$lower)">
        <xsl:value-of select="@alpha2"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="alpha3">
      <xsl:for-each select="key('ctrya3',$upper)">
        <xsl:value-of select="@alpha2"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="($name != '')"><xsl:value-of select="$name"/></xsl:when>
      <xsl:when test="($alpha3 != '')"><xsl:value-of select="$alpha3"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$original"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="languageCodes">
    <xsl:param name="lower" />
    <xsl:param name="original" />
    <xsl:variable name="name">
      <xsl:for-each select="key('langName',$lower)">
        <xsl:value-of select="@alpha3"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="alpha2">
      <xsl:for-each select="key('langa2',$lower)">
        <xsl:value-of select="@alpha3"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="alpha3t">
      <xsl:for-each select="key('langa3t',$lower)">
        <xsl:value-of select="@alpha3"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="alpha3">
      <xsl:for-each select="key('langa3',$lower)">
        <xsl:value-of select="@alpha3"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="($name != '')"><xsl:value-of select="$name"/></xsl:when>
      <xsl:when test="($alpha2 != '')"><xsl:value-of select="$alpha2"/></xsl:when>
      <xsl:when test="($alpha3t != '')"><xsl:value-of select="$alpha3t"/></xsl:when>
      <xsl:when test="($alpha3 != '')"><xsl:value-of select="$alpha3"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$original"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
