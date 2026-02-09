<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
  <body>
  <h2>Новые поступления книг</h2>
  <ul>
    <xsl:for-each select="books/book">
    <li>
      <span><xsl:value-of select="title"/></span> – 
      <span><xsl:value-of select="author"/></span>, 
      <span><xsl:value-of select="price"/> руб.</span>
    </li>
    </xsl:for-each>
  </ul>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet>

