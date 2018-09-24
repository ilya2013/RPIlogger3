<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output version="1.0" indent="yes" encoding="UTF-8" method="text"/>
    <xsl:key use="p0" match="line" name="grp"/>
    <xsl:variable name="lowCase">абвгдеёжзийклмнопрстуфхцчшщыъьэюяabcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="upCase">АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЪЬЭЮЯABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:template match="uforegimport">
        <xsl:apply-templates select="line[generate-id(.)=generate-id(key('grp', p0))]"/>
    </xsl:template>
    <xsl:template match="line">
        <xsl:variable name="pacc" select="key('grp', p0)"/>
        <xsl:text>PACC: </xsl:text><xsl:value-of select="p0"/><xsl:text>| </xsl:text><xsl:text>SUMMA: </xsl:text>
        <xsl:variable name="sum" select="format-number(number(sum($pacc/p7[. > 0])) div 100, '#0.00')"/>
        <xsl:choose>
            <xsl:when test="$sum > 0">
                <xsl:value-of select="$sum"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0.00</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>| </xsl:text><xsl:text>NAZN:</xsl:text><xsl:text> persAcc: </xsl:text><xsl:value-of select="p0"/><xsl:text>;</xsl:text>
        <xsl:choose>
            <xsl:when test="normalize-space(substring-before(normalize-space(p1), ' ')) = ''">
                <xsl:text> lastName: </xsl:text>
                <xsl:choose>
                    <xsl:when test="p1!=''">
                        <xsl:value-of select="normalize-space(p1)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>-</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>;</xsl:text><xsl:text> firstName: </xsl:text><xsl:text>-;</xsl:text><xsl:text> middleName: </xsl:text><xsl:text>-;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> lastName: </xsl:text><xsl:value-of select="substring-before(normalize-space(p1), ' ')"/><xsl:text>;</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(normalize-space(substring-after(normalize-space(p1), ' ')), ' ')">
                        <xsl:text> firstName: </xsl:text><xsl:value-of
                            select="normalize-space(substring-before(normalize-space(substring-after(normalize-space(p1), ' ')), ' '))"/><xsl:text>;</xsl:text><xsl:text> middleName: </xsl:text><xsl:value-of
                            select="normalize-space(substring-after(normalize-space(substring-after(normalize-space(p1), ' ')), ' '))"/><xsl:text>;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> firstName: </xsl:text><xsl:value-of
                            select="normalize-space(substring-after(normalize-space(p1), ' '))"/><xsl:text>;</xsl:text><xsl:text> middleName: </xsl:text><xsl:text>-;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> payerAddress: </xsl:text>
        <xsl:choose>
            <xsl:when test="p2!=''">
                <xsl:value-of select="p2"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>-</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
        <xsl:for-each select="$pacc">
            <xsl:sort select="p3"/>
            <xsl:text> serviceName</xsl:text><xsl:text>: </xsl:text>
            <xsl:choose>
                <xsl:when test="p3!=''">
                    <xsl:value-of select="p3"/><xsl:text/><xsl:value-of select="p4"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>-</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text><xsl:text> paymPeriod</xsl:text><xsl:text>: </xsl:text>
            <xsl:choose>
                <xsl:when test="p5=''">
                    <xsl:text>012001</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="p5"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:if test="p6!=''">
                <xsl:text> counterVal</xsl:text><xsl:text>: </xsl:text><xsl:value-of select="p6"/><xsl:text>;</xsl:text><xsl:text> counterValOld</xsl:text><xsl:text>: </xsl:text><xsl:value-of
                    select="p6"/><xsl:text>;</xsl:text>
            </xsl:if>
            <xsl:text> subsrv</xsl:text><xsl:text>: </xsl:text>
            <xsl:choose>
                <xsl:when test="p7 > 0">
                    <xsl:value-of select="format-number(number(p7) div 100, '#0.00')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0.00</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:if test="p8!=''">
                <xsl:text> Tariff: </xsl:text><xsl:value-of select="p8"/><xsl:text>;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text> NORM_ADDRESS: </xsl:text>
        <xsl:variable name="addr" select="translate(p2,$lowCase, $upCase)"/>
        <!--Переводим адрес в верхний регистр-->
        <xsl:variable name="part1" select="substring-before($addr,',')"/>
        <xsl:variable name="temp1" select="substring-after($addr,',')"/>
        <xsl:variable name="part2" select="substring-before($temp1,',')"/>
        <xsl:variable name="temp2" select="substring-after($temp1,',')"/>
        <xsl:variable name="street">
            <xsl:choose>
                <xsl:when test="contains($part2,'М-ОН')">
                    <xsl:value-of select="concat(normalize-space(substring-before($part2,'М-ОН')),' МИКРОРАЙОН')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$part2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="part3" select="substring-before($temp2,',')"/>
        <xsl:variable name="temp3" select="substring-after($temp2,',')"/>
        <xsl:variable name="part4">
            <xsl:choose>
                <xsl:when test="contains($temp3,',')">
                    <xsl:value-of select="substring-before($temp3,',')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temp3"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="normCity">
            <xsl:with-param name="str" select="normalize-space($part1)"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="normStreet">
            <xsl:with-param name="str" select="normalize-space($street)"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="normHouse">
            <xsl:with-param name="str" select="normalize-space($part3)"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="normFlat">
            <xsl:with-param name="str" select="normalize-space($part4)"/>
        </xsl:call-template>
        <xsl:text>;</xsl:text><xsl:text>|</xsl:text><xsl:text> </xsl:text>
    </xsl:template>
    <!-- =================================================================== -->
    <!-- Шаблон получения номера дома -->
    <xsl:template name="getNum">
        <xsl:param name="str"/>
        <xsl:variable name="templ">
            <xsl:value-of select="translate($str,'\-(','////')"/>
        </xsl:variable>
        <xsl:variable name="templ1">
            <xsl:choose>
                <xsl:when test="contains($templ,'/') or contains(normalize-space($templ),' ') ">
                    <xsl:choose>
                        <xsl:when
                                test="(contains(translate(substring-after($templ,'/'),'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЪЬЭЮЯ','+++++++++++++++++++++++++++++++++'),'+') and contains(translate(substring-before($templ,'/'),'0123456789','++++++++++'),'+')) or (contains(translate(substring-after(normalize-space($templ),' '),'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЪЬЭЮЯ','+++++++++++++++++++++++++++++++++'),'+') and contains(translate(substring-before(normalize-space($templ),' '),'0123456789','++++++++++'),'+'))">
                            <xsl:value-of select="translate($templ,'/ ','')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$templ"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$templ"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                    test="(contains($templ1,'/') and string-length(substring-after($templ1,'/'))=0) or (string-length(substring-after($templ1,'/'))=1 and substring-after($templ1,'/')='/') or (string-length(substring-after($templ1,'/'))=2 and substring-after($templ1,'/')='//')">
                <xsl:choose>
                    <xsl:when test="$templ1='0/'">
                        <xsl:value-of select="translate(substring-before($templ1,'/'),'0','')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before($templ1,'/')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="starts-with(substring-after($templ1,'/'),'/')">
                <xsl:call-template name="delSlash">
                    <xsl:with-param name="strr" select="$templ1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($templ1,'КОР')">
                <xsl:call-template name="getNum">
                    <xsl:with-param name="str" select="translate($templ1,'КОРПУС.','/')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($templ1,'КОМ')">
                <xsl:call-template name="getNum">
                    <xsl:with-param name="str" select="translate($templ1,'КОМНАТА.','/')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$templ1='0'">
                        <xsl:value-of select="translate($templ1,'0','')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$templ1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- =================================================================== -->
    <xsl:template name="delSlash">
        <xsl:param name="strr"/>
        <xsl:variable name="ssttrr">
            <xsl:value-of
                    select="concat(concat(substring-before($strr,'/'),'/'),translate(substring-after($strr,'/'),'/',''))"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$ssttrr='0'">
                <xsl:value-of select="translate($ssttrr,'0','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$ssttrr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--Обработка реквизита "Дом"-->
    <xsl:template name="normHouse">
        <xsl:param name="str"/>
        <xsl:variable name="rez">
            <xsl:choose>
                <xsl:when test="contains($str,'Д.') and string-length(substring-before($str,'Д.'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'Д.'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ДОМ')">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'ДОМ'),substring-after($str,'ДОМ')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПОЗ')">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'ПОЗ'),substring-after($str,'ПОЗ')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'БЛОК')">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'БЛОК'),substring-after($str,'БЛОК')))"/>
                </xsl:when>
                <xsl:when
                        test="contains($str,'Д') and contains(translate(substring-after($str,'Д'),'0123456789','++++++++++'),'+') and string-length(substring-before($str,'Д'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'Д'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$str"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="getNum">
            <xsl:with-param name="str" select="$rez"/>
        </xsl:call-template>
    </xsl:template>
    <!--Обработка реквизита "Город/Населенный пункт"-->
    <xsl:template name="normCity">
        <xsl:param name="str"/>
        <xsl:choose>
            <xsl:when test="contains($str,'Д.') and string-length(substring-before($str,'Д.'))=0">
                <xsl:value-of select="normalize-space(substring-after($str,'Д.'))"/>
            </xsl:when>
            <xsl:when test="contains($str,'Г.') and string-length(substring-before($str,'Г.'))=0">
                <xsl:value-of select="normalize-space(substring-after($str,'Г.'))"/>
            </xsl:when>
            <xsl:when test="contains($str,'П.') and string-length(substring-before($str,'П.'))=0">
                <xsl:value-of select="normalize-space(substring-after($str,'П.'))"/>
            </xsl:when>
            <xsl:when test="contains($str,'С.') and string-length(substring-before($str,'С.'))=0">
                <xsl:value-of select="normalize-space(substring-after($str,'С.'))"/>
            </xsl:when>
            <xsl:when test="contains($str,'СТ ') and string-length(substring-before($str,'СТ '))=0">
                <xsl:value-of select="normalize-space(substring-after($str,'СТ '))"/>
            </xsl:when>
            <xsl:when
                    test="contains($str,'ПГТ') and (string-length(substring-before($str,'ПГТ'))=0 or string-length(substring-after($str,'ПГТ')) < 2)">
                <xsl:value-of
                        select="normalize-space(concat(substring-before($str,'ПГТ'),substring-after($str,'ПГТ')))"/>
            </xsl:when>
            <xsl:when
                    test="contains($str,'СНТ') and (string-length(substring-before($str,'СНТ'))=0 or string-length(substring-after($str,'СНТ')) < 2)">
                <xsl:value-of
                        select="normalize-space(concat(substring-before($str,'СНТ'),substring-after($str,'СНТ')))"/>
            </xsl:when>
            <xsl:when
                    test="contains($str,'П/СТ') and (string-length(substring-before($str,'П/СТ'))=0 or string-length(substring-after($str,'П/СТ')) < 2)">
                <xsl:value-of
                        select="normalize-space(concat(substring-before($str,'П/СТ'),substring-after($str,'П/СТ')))"/>
            </xsl:when>
            <xsl:when test="contains($str,' Г') and string-length(substring-after($str,' Г')) < 2">
                <xsl:value-of select="normalize-space(substring-before($str,' Г'))"/>
            </xsl:when>
            <xsl:when test="contains($str,' Д') and string-length(substring-after($str,' Д')) < 2">
                <xsl:value-of select="normalize-space(substring-before($str,' Д'))"/>
            </xsl:when>
            <xsl:when test="contains($str,' П') and string-length(substring-after($str,' П')) < 2">
                <xsl:value-of select="normalize-space(substring-before($str,' П'))"/>
            </xsl:when>
            <xsl:when test="contains($str,' C') and string-length(substring-after($str,' C')) < 2">
                <xsl:value-of select="normalize-space(substring-before($str,' C'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--Обработка улицы-->
    <xsl:template name="normStreet">
        <xsl:param name="str"/>
        <xsl:variable name="rez">
            <xsl:choose>
                <xsl:when test="contains($str,'УЛ.') and string-length(substring-before($str,'УЛ.'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'УЛ.'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'УЛ ') and string-length(substring-before($str,'УЛ '))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'УЛ '))"/>
                </xsl:when>
                <xsl:when test="contains($str,'MИК-ОН') and string-length(substring-before($str,'MИК-ОН'))=0 ">
                    <xsl:value-of select="concat('МИКРОРАЙОН ',normalize-space(substring-after($str,'MИК-ОН')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'MИК-ОН') and string-length(substring-after($str,'MИК-ОН')) < 2">
                    <xsl:value-of select="concat(normalize-space(substring-before($str,'MИК-ОН')),' МИКРОРАЙОН')"/>
                </xsl:when>
                <xsl:when test="contains($str,'MКР') and string-length(substring-before($str,'MКР'))=0 ">
                    <xsl:value-of select="concat('МИКРОРАЙОН ',normalize-space(substring-after($str,'MКР')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'MКР') and string-length(substring-after($str,'MКР')) < 2">
                    <xsl:value-of select="concat(normalize-space(substring-before($str,'MКР')),' МИКРОРАЙОН')"/>
                </xsl:when>
                <xsl:when test="contains($str,'МР-Н') and string-length(substring-before($str,'МР-Н'))=0 ">
                    <xsl:value-of select="concat('МИКРОРАЙОН ',normalize-space(substring-after($str,'МР-Н')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'МР-Н') and string-length(substring-after($str,'МР-Н')) < 2">
                    <xsl:value-of select="concat(normalize-space(substring-before($str,'МР-Н')),' МИКРОРАЙОН')"/>
                </xsl:when>
                <xsl:when
                        test="contains($str,'Р-ОН') and (string-length(substring-before($str,'Р-ОН'))=0 or string-length(substring-after($str,'Р-ОН')) < 2)">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'Р-ОН'),substring-after($str,'Р-ОН')))"/>
                </xsl:when>
                <xsl:when
                        test="contains($str,'Р-Н') and (string-length(substring-before($str,'Р-Н'))=0 or string-length(substring-after($str,'Р-Н')) < 2)">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'Р-Н'),substring-after($str,'Р-Н')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'КВ-Л') and string-length(substring-before($str,'КВ-Л'))=0 ">
                    <xsl:value-of select="concat('КВАРТАЛ ',normalize-space(substring-after($str,'КВ-Л')))"/>
                </xsl:when>
                <xsl:when test="contains($str,'КВ-Л') and string-length(substring-after($str,'КВ-Л')) < 2">
                    <xsl:value-of select="concat(normalize-space(substring-before($str,'КВ-Л')),' КВАРТАЛ')"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПЕР.') and string-length(substring-before($str,'ПЕР.'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПЕР.'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПЕР ') and string-length(substring-before($str,'ПЕР '))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПЕР '))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПР.') and string-length(substring-before($str,'ПР.'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПР.'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПР ') and string-length(substring-before($str,'ПР '))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПР '))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПЛ.') and string-length(substring-before($str,'ПЛ.'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПЛ.'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПЛ ') and string-length(substring-before($str,'ПЛ '))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПЛ '))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПР-Т') and string-length(substring-before($str,'ПР-Т'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПР-Т'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПР-Т') and string-length(substring-after($str,'ПР-Т')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,'ПР-Т'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПР-КТ') and string-length(substring-before($str,'ПР-КТ'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'ПР-КТ'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'ПР-КТ') and string-length(substring-after($str,'ПР-КТ')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,'ПР-КТ'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'П-Т') and string-length(substring-before($str,'П-Т'))=0">
                    <xsl:value-of select="normalize-space(substring-after($str,'П-Т'))"/>
                </xsl:when>
                <xsl:when test="contains($str,'П-Т') and string-length(substring-after($str,'П-Т')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,'П-Т'))"/>
                </xsl:when>
                <xsl:when test="contains($str,' ПР') and string-length(substring-after($str,' ПР')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,' ПР'))"/>
                </xsl:when>
                <xsl:when test="contains($str,' СП') and string-length(substring-after($str,' СП')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,' СП'))"/>
                </xsl:when>
                <xsl:when test="contains($str,' ПЕР') and string-length(substring-after($str,' ПЕР')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,' ПЕР'))"/>
                </xsl:when>
                <xsl:when test="contains($str,' ПЛ') and string-length(substring-after($str,' ПЛ')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,' ПЛ'))"/>
                </xsl:when>
                <xsl:when test="contains($str,' УЛ') and string-length(substring-after($str,' УЛ')) < 2">
                    <xsl:value-of select="normalize-space(substring-before($str,' УЛ'))"/>
                </xsl:when>
                <xsl:when
                        test="contains($str,'СПУСК') and (string-length(substring-before($str,'СПУСК'))=0 or string-length(substring-after($str,'СПУСК')) < 2)">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'СПУСК'),substring-after($str,'СПУСК')))"/>
                </xsl:when>
                <xsl:when
                        test="contains($str,'ШОССЕ') and (string-length(substring-before($str,'ШОССЕ'))=0 or string-length(substring-after($str,'ШОССЕ')) < 2)">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'ШОССЕ'),substring-after($str,'ШОССЕ')))"/>
                </xsl:when>
                <xsl:when
                        test="contains($str,'ПЕРЕУЛОК') and (string-length(substring-before($str,'ПЕРЕУЛОК'))=0 or string-length(substring-after($str,'ПЕРЕУЛОК')) < 2)">
                    <xsl:value-of
                            select="normalize-space(concat(substring-before($str,'ПЕРЕУЛОК'),substring-after($str,'ПЕРЕУЛОК')))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$str"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($rez,'-')">
                <xsl:variable name="val">
                    <xsl:choose>
                        <xsl:when test="contains($rez,'-Я')">
                            <xsl:value-of select="'-Я'"/>
                        </xsl:when>
                        <xsl:when test="contains($rez,'-Й')">
                            <xsl:value-of select="'-Й'"/>
                        </xsl:when>
                        <xsl:when test="contains($rez,'-ОГО')">
                            <xsl:value-of select="'-ОГО'"/>
                        </xsl:when>
                        <xsl:when test="contains($rez,'-ГО')">
                            <xsl:value-of select="'-ГО'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when
                            test="contains($rez,$val) and substring(translate(substring-before($rez,$val),'0123456789','++++++++++'),string-length(translate(substring-before($rez,$val),'0123456789','++++++++++')),1)='+'">
                        <xsl:value-of
                                select="normalize-space(concat(concat(normalize-space(substring-before($rez,$val)),' '),normalize-space(substring-after($rez,$val))))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$rez"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$rez"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="normFlat">
        <xsl:param name="str"/>
        <xsl:choose>
            <xsl:when
                    test="contains($str,'КВ.') and (string-length(substring-before($str,'КВ.'))=0 or string-length(substring-after($str,'КВ.')) < 2)">
                <xsl:call-template name="getNum">
                    <xsl:with-param name="str"
                                    select="normalize-space(concat(substring-before($str,'КВ.'),substring-after($str,'КВ.')))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                    test="contains($str,'ГАРАЖ') and (string-length(substring-before($str,'ГАРАЖ'))=0 or string-length(substring-after($str,'ГАРАЖ')) < 2)">
                <xsl:call-template name="getNum">
                    <xsl:with-param name="str"
                                    select="normalize-space(concat(substring-before($str,'ГАРАЖ'),substring-after($str,'ГАРАЖ')))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($str,' Г') and string-length(substring-after($str,' Г')) < 2">
                <xsl:call-template name="getNum">
                    <xsl:with-param name="str" select="normalize-space(substring-before($str,' Г'))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getNum">
                    <xsl:with-param name="str" select="$str"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
