# bible-sql-mysql
Bible database for MySQL

## Flavors ##

- [SQL Server](https://github.com/donjewett/bible-sql/)
- [MySQL/MariaDB](https://github.com/donjewett/bible-sql-mysql/)
- [PostgreSQL](https://github.com/donjewett/bible-sql-postgresql/)
- [SQLite](https://github.com/donjewett/bible-sql-sqlite/)
- [Firebird](https://github.com/donjewett/bible-sql-firebird/)

## Organization ##
Bible tables are arranged in a hierarchy:

- Canon
	- Section
		- Book
			- Chapter
				- Verse

**Canon**s are the highest level, following Protestant tradition.

- Old Testament 
- New Testament

The bible database does not currently include the Apocryphal books (Deuterocanon), but these may be included at a later date, or in a separate repository. If so, it should have the Id 200000000.

**Sections** provide organization by major categories:

Old Testament

- Law
- History
- Wisdom
- Major Prophets
- Minor Prophets

New Testament

- Gospels
- Acts
- Pauline Epistles
- General Epistles
- Revelation

**Verses** provide the lowest level of the hierarchy. This table *does not* include verse content, which is supplied by another set of tables.

Since this data is static, the table includes the complete hierarchy (like a star schema) for fewer joins while querying. It has been designed for easy querying rather than easy updates.


## Numbering Convention ##

The hierarchy of tables described above follow a numbering convention for Primary Keys.

Each key is a 4 byte integer (int) nine digits long. The first digit corresponds to the Canon, the next 2 digits to the Book, with 3 digits each for Chapter and Verse. This allows the hierarchy to be derived from the key (except the Section).

For example, this the hierarchy of Genesis 1:1

- 100000000 - Old Testament (canon 1)
- 101000000 - Law (section - same key as Genesis)
- 101000000 - Genesis (book 1)
- 101001000 - Genesis 1 (chapter 1)
- 101001001 - Genesis 1:1 (verse 1)

The hierarchy of Psalm 119:169

- 100000000 - Old Testament (canon)
- 118000000 - Wisdom (section)
- 119000000 - Psalms (book)
- 119119000 - Psalm 119 (chapter)
- 119119169 - Psalm 119:169 (verse)

The hierarchy of 2 Timothy 3:16

- 300000000 - New Testament (canon)
- 345000000 - Pauline Epistles (section)
- 355000000 - 2 Timothy (book)
- 355003000 - 2 Timothy 3 (chapter)
- 355003016 - 2 Timothy 3:16 (verse)


The keys for Section match the first Book in the Section. This limitation is imposed to keep the Ids within a 4 byte integer and still allow for the encoding of more than 2 Ids for Canon. Encoding a Section would have required an 8 byte integer (bigint) since the maximum 4 byte integer in SQL Server is 2147483647.

## Verse Content ##

Another hierarchy of tables manages Bible Content:

- Versions
	- Editions
		- Bibles
			- BibleVerses

The **Versions** table is for a specific version such as the KJV (King James Version/Authorized Version) or NIV (New International Version).

This allows versions to be tracked along with their specific licenses without their content existing in the database. Commercially licensed bible content is not provided in this repository.

The **Editions** table is for the editions of a version which have been published over time. For example, The NIV was originally released in 1978 with a minor revision in 1984 and major revision in 2011. The KJV edition in widespread use today is from 1769, though the original was published in 1611.

Editions are not for things like a Study Bible or special editions. A Study Bible using the 1984 Edition of the NIV would use 1984 for the Edition and the Study Bible should go in the Bibles table:

The **Bibles** table is for specific bibles. The database can contain multiple versions of a single edition. 

For example, while refining the KJV script, numerous sources were used, including:

- https://ebible.org/find/show.php?id=eng-kjv2006
- https://jsonbible.com/
- https://viz.bible/
- http://biblehub.info/data/bibles.xlsx
- http://www.bibleprotector.com/bible.sql
- https://web.archive.org/web/20200801034359/http://getbible.net/scriptureinstall/English__King_James_Version__kjv__LTR.txt
- https://sacred-texts.com/bib/osrc/kjvdat.zip
- https://web.archive.org/web/20121210130518/http://patriot.net/~bmcgin/kjv12.zip

Each of these Bibles were imported into the database and compared verse-by-verse, but they had the 1769 Edition of the KJV in common (or similar). 

Another use for separate bibles would be for different formats, such as:

- text markup (the bibles provided so far in the repository) 
- html, json, or xml
- html markup containing Strong's numbers.
- A Study Bible with notes

The **BibleVerses** table contains the actual bible content.

The Notes column is for in-line notes which come with some Editions. 

The PreMarkup and PostMarkup columns are for in-line text which exists in the manuscript tradition but are not considered verse content. 

An example of this is the headings in Psalm 119. Psalm 119 has a set of verses for each of the Hebrew letters and those verses start with that letter in the Hebrew original. So Psalm 119:1 might have the Heading "ALEPH" or "ALEPH ℵ" depending on the edition.

Another example is the titles in the Psalms. Psalm 110:1 might have the heading "A Psalm of David" where the edition includes this as a heading for the verse. The heading is canonical, in that it does exist in the manuscripts. Whether the headings are original is debated. Only 116 Psalms have titles in the Masoretic Text, but the LXX (Septuagint) has them in all but two ([source](https://reformedreader.wordpress.com/2009/11/09/the-titles-of-the-psalms-original/)).

## Additional Tables ##

Additional tables are included for:

- Language (such as Hebrew or Greek)
- Licensing (such as Public Domain or Creative Commons)
- Text Forms (such as Alexandrian or Byzantine)
- Resources (such as download links for original files)

## Schema ##

[Browseable schema document](https://htmlpreview.github.io/?https://raw.githubusercontent.com/donjewett/bible-sql-mysql/main/docs/bible-schema.htm)

[updated 2024-10-15]
