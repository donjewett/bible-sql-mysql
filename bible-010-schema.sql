/* *************************************************************************
Bible Database: MySQL/MariaDB, by Don Jewett
https://github.com/donjewett/bible-sql-mysql

bible-010-schema.sql
Version: 2025.10.31

************************************************************************* */

-- -------------------------------------------------------------------------
-- Languages
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Languages (
	Id char(3) CHARACTER SET ascii NOT NULL COMMENT 'Three character ISO 693-1 code',
	Name varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Name of the Language in English',
	HtmlCode char(2) CHARACTER SET ascii NOT NULL COMMENT 'Two character html code for Language',
	IsAncient boolean NOT NULL DEFAULT false COMMENT 'This language or dialect has been extinct since ancient times',
	PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- Canons
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Canons (
	Id int NOT NULL COMMENT 'Canon Id following bible-sql numbering scheme',
	Code char(2) CHARACTER SET ascii NOT NULL COMMENT 'Short code following Protestant tradition',
	Name varchar(24) CHARACTER SET ascii NOT NULL COMMENT 'Name following Protestant tradition',
	LanguageId char(3) CHARACTER SET ascii NOT NULL COMMENT 'Primary Language of the Canon',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Canons_Languages FOREIGN KEY (LanguageId) REFERENCES Languages (Id)
);

-- -------------------------------------------------------------------------
-- Sections
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Sections (
	Id int NOT NULL COMMENT 'Section Id following bible-sql numbering scheme',
	Name varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Name of the Section following Protestant tradition',
	CanonId int NOT NULL COMMENT 'Canon of the Bible Section',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Sections_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id)
);

-- -------------------------------------------------------------------------
-- Books
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Books (
	Id int NOT NULL COMMENT 'Book Id following bible-sql numbering scheme',
	Code varchar(5) CHARACTER SET ascii NOT NULL COMMENT 'Short url-friendly lowercase Code for Book',
	Abbrev varchar(5) CHARACTER SET ascii NOT NULL COMMENT 'Short Proper case abbreviation for Book',
	Name varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Name of Book following Protestant tradition',
	Book tinyint NOT NULL COMMENT 'Index of Book following Protestant order',
	CanonId int NOT NULL COMMENT 'Canon of Book following Protestant tradition', -- denormalized
	SectionId int NOT NULL COMMENT 'Section of Book following Protestant tradition',
	IsSectionEnd boolean NOT NULL DEFAULT false COMMENT 'Is the final Book in the Section',
	ChapterCount smallint NOT NULL COMMENT 'Count of chapters in this book following Protestant tradition',
	OsisCode varchar(6) CHARACTER SET ascii NOT NULL COMMENT 'Osis code for the Book',
	Paratext char(3) CHARACTER SET ascii NOT NULL COMMENT 'Paratext code for the Book',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Books_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_Books_Sections FOREIGN KEY (SectionId) REFERENCES Sections (Id)
);

-- -------------------------------------------------------------------------
-- BookNames
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BookNames (
	Name varchar(64) CHARACTER SET ascii NOT NULL COMMENT 'Altername name or code for Book',
	BookId int NOT NULL COMMENT 'Book Id following bible-sql numbering scheme',
	PRIMARY KEY (Name),
	CONSTRAINT FK_BookNames_Books FOREIGN KEY (BookId) REFERENCES Books (Id)
);

-- -------------------------------------------------------------------------
-- Chapters
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Chapters (
	Id int NOT NULL COMMENT 'Chapter Id following bible-sql numbering scheme',
	Code varchar(7) CHARACTER SET ascii NOT NULL COMMENT 'Short, url-friendly lowercase Code for chapter',
	Reference varchar(8) CHARACTER SET ascii NOT NULL COMMENT 'Human readable reference using Book Abbrev and Chapter number',
	Chapter smallint NOT NULL COMMENT 'Chapter number',
	BookId int NOT NULL COMMENT 'Book of the Chapter',
	IsBookEnd boolean NOT NULL DEFAULT false COMMENT 'Is the final Chapter in the Book',
	VerseCount smallint NOT NULL COMMENT 'Count of verses in the Chapter',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Chapters_Books FOREIGN KEY (BookId) REFERENCES Books (Id)
);

-- -------------------------------------------------------------------------
-- Verses
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Verses (
	Id int NOT NULL COMMENT 'Verse Id following bible-sql numbering scheme',
	Code varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Short, url-friendly lowercase Code for verse',
	OsisCode varchar(12) CHARACTER SET ascii NOT NULL COMMENT 'Osis code for the Verse',
	Reference varchar(10) CHARACTER SET ascii NOT NULL COMMENT 'Human readable reference using Book Abbrev Chapter:Verse',
	CanonId int NOT NULL COMMENT 'Canon of the Verse', -- denormalized
	SectionId int NOT NULL COMMENT 'Section of the Verse', -- denormalized
	BookId int NOT NULL COMMENT 'Book of the Verse', -- denormalized
	ChapterId int NOT NULL COMMENT 'Chapter of the Verse',
	IsChapterEnd boolean NOT NULL DEFAULT false COMMENT 'Is the final Verse in the Chapter',
	Book tinyint NOT NULL COMMENT 'Book number', -- denormalized
	Chapter tinyint NOT NULL COMMENT 'Chapter number', -- denormalized
	Verse smallint NOT NULL COMMENT 'Verse number',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Verses_Books FOREIGN KEY (BookId) REFERENCES Books (Id),
	CONSTRAINT FK_Verses_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters (Id),
	CONSTRAINT FK_Verses_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_Verses_Sections FOREIGN KEY (SectionId) REFERENCES Sections (Id)
);

-- -------------------------------------------------------------------------
-- GreekTextForms
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS GreekTextForms (
	Id char(3) CHARACTER SET ascii NOT NULL COMMENT 'One to three character code for Greek form',
	Name varchar(48) CHARACTER SET ascii NOT NULL COMMENT 'Name of the Greek form',
	ParentId char(3) CHARACTER SET ascii NULL COMMENT 'The Greek form this one derives from',
	PRIMARY KEY (Id),
	CONSTRAINT FK_GreekTextForms_GreekTextForms FOREIGN KEY (ParentId) REFERENCES GreekTextForms (Id)
);

-- -------------------------------------------------------------------------
-- HebrewTextForms
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS HebrewTextForms (
	Id char(3) CHARACTER SET ascii NOT NULL COMMENT 'One to three character code for Hebrew text',
	Name varchar(48) CHARACTER SET ascii NOT NULL COMMENT 'Name of the Hebrew form',
	ParentId char(3) CHARACTER SET ascii NULL COMMENT 'The Hebrew form this one derives from',
	PRIMARY KEY (Id),
	CONSTRAINT FK_HebrewTextForms_GHebrewTextForms FOREIGN KEY (ParentId) REFERENCES HebrewTextForms (Id)
);

-- -------------------------------------------------------------------------
-- LicensePermissions
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LicensePermissions (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	Name varchar(48) CHARACTER SET ascii NOT NULL COMMENT 'Name of the Permission',
	Permissiveness int NOT NULL COMMENT 'Permissiveness of license on a scale of 0 to 100',
	PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- LicenseTypes
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LicenseTypes (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	Name varchar(64) CHARACTER SET ascii NOT NULL COMMENT 'Name of the License Type',
	IsFree boolean NOT NULL DEFAULT false COMMENT 'True for licences allowing free quotation -- false for commercial restricting use',
	PermissionId int NULL COMMENT 'Permissiveness for License Type',
	PRIMARY KEY (Id),
	CONSTRAINT FK_LicenseTypes_LicensePermissions FOREIGN KEY (PermissionId) REFERENCES LicensePermissions (Id)
);

-- -------------------------------------------------------------------------
-- Versions
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Versions (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	Code varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Version Code used for lookups. Must be unique',
	Name varchar(64) CHARACTER SET utf8 NOT NULL COMMENT 'Name of the Version',
	Subtitle varchar(128) CHARACTER SET utf8 NULL COMMENT 'Optional Subtitle for the version',
	LanguageId char(3) CHARACTER SET ascii NOT NULL COMMENT 'Language of the Version',
	YearPublished smallint NOT NULL COMMENT 'Year first published in entirety',
	HebrewFormId char(3) CHARACTER SET ascii NULL COMMENT 'Textual basis for the Old Testament',
	GreekFormId char(3) CHARACTER SET ascii NULL COMMENT 'Textual basis for the New Testament',
	ParentId int NULL COMMENT 'Optional Version this is derived from',
	LicenseTypeId int NULL COMMENT 'Optional License Type',
	ReadingLevel decimal(4,2) NULL COMMENT 'Reading Level using U.S. school grades (8.0 = Eighth Grade)',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Versions_Languages FOREIGN KEY (LanguageId) REFERENCES Languages (Id),
	CONSTRAINT FK_Versions_Versions FOREIGN KEY (ParentId) REFERENCES Versions (Id),
	CONSTRAINT FK_Versions_GreekTextForms FOREIGN KEY (GreekFormId) REFERENCES GreekTextForms (Id),
	CONSTRAINT FK_Versions_HebrewTextForms FOREIGN KEY (HebrewFormId) REFERENCES HebrewTextForms (Id),
	CONSTRAINT FK_Versions_LicenseTypes FOREIGN KEY (LicenseTypeId) REFERENCES LicenseTypes (Id)
);

-- -------------------------------------------------------------------------
-- Revisions
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Revisions (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	Code varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Revision Code used for lookups. Must be unique',
	VersionId int NOT NULL COMMENT 'Version of the Revision',
	YearPublished smallint NOT NULL COMMENT 'Year the Revision was first published in its entirety',
	Subtitle varchar(128) CHARACTER SET utf8 NULL COMMENT 'Subtitle for the Revision, esp. if different than Version (i.e. Second Revision)',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Revisions_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id)
);

-- -------------------------------------------------------------------------
-- Sites
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Sites (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	Name varchar(64) CHARACTER SET utf8 NOT NULL COMMENT 'Site Name',
	Url varchar(255) CHARACTER SET ascii NULL COMMENT 'Site Url',
	PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- ResourceTypes
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ResourceTypes (
	Id varchar(8) CHARACTER SET ascii NOT NULL COMMENT 'Eight character code',
	Name varchar(64) CHARACTER SET ascii NOT NULL COMMENT 'Name of the Resource Type',
	PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- Resources
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Resources (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	ResourceTypeId varchar(8) CHARACTER SET ascii NOT NULL COMMENT 'Eight character code for Resource Type',
	VersionId int NOT NULL COMMENT 'Version of the Resource',
	RevisionId int NULL COMMENT 'Optional Revision of the Resource',
	Url varchar(255) CHARACTER SET ascii NULL COMMENT 'Source Url for the Resource',
	IsOfficial boolean NOT NULL DEFAULT false COMMENT 'True if the Resource is the official one (i.e. provided by the publisher)',
	SiteId int NULL COMMENT 'Site associated with the Resource',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Resources_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_Resources_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_Resources_ResourceTypes FOREIGN KEY (ResourceTypeId) REFERENCES ResourceTypes (Id),
	CONSTRAINT FK_Resources_Sites FOREIGN KEY (SiteId) REFERENCES Sites (Id)
);

-- -------------------------------------------------------------------------
-- Bibles
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Bibles (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	Code varchar(16) CHARACTER SET ascii NOT NULL COMMENT 'Code for lookups. Must be unique',
	Name varchar(64) CHARACTER SET utf8 NOT NULL COMMENT 'Code for lookups. Must be unique',
	Subtitle varchar(128) CHARACTER SET utf8 NULL COMMENT 'Subtitle for this specific Bible',
	VersionId int NOT NULL COMMENT 'Version of this Bible',
	RevisionId int NULL COMMENT 'Optional Revision of this Bible',
	YearPublished smallint NULL COMMENT 'Year this Bible (or Revision) was published',
	TextFormat varchar(6) CHARACTER SET ascii NOT NULL DEFAULT ('txt') COMMENT 'Code for the format of the Content',
	SourceId int NULL COMMENT 'Optional source Resource of this Bible',
	PRIMARY KEY (Id),
	CONSTRAINT FK_Bibles_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_Bibles_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_Bibles_Resources FOREIGN KEY (SourceId) REFERENCES Resources (Id)
);

-- -------------------------------------------------------------------------
-- BibleVerses
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BibleVerses (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	BibleId int NOT NULL COMMENT 'The Bible for this Content',
	VerseId int NOT NULL COMMENT 'The Verse for this Content',
	Markup text NOT NULL COMMENT 'The Content of the Bible Verse',
	PreMarkup varchar(255) CHARACTER SET utf8 NULL COMMENT 'Optional Markup, especially for scribal notes in the manuscripts.',
	PostMarkup varchar(255) CHARACTER SET utf8 NULL COMMENT 'Optional Markup, especially for scribal notes in the manuscripts.',
	Notes varchar(255) CHARACTER SET utf8 NULL COMMENT 'Optional Notes for the Bible Verse',
	PRIMARY KEY (Id),
	CONSTRAINT FK_BibleVerses_Bibles FOREIGN KEY (BibleId) REFERENCES Bibles (Id),
	CONSTRAINT FK_BibleVerses_Verses FOREIGN KEY (VerseId) REFERENCES Verses (Id)
);

CREATE UNIQUE INDEX IF NOT EXISTS UQ_BibleVerses_Version_Verse ON BibleVerses
(
	BibleId ASC,
	VerseId ASC
);

-- -------------------------------------------------------------------------
-- VersionNotes
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VersionNotes (
	Id int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Id',
	VersionId int NOT NULL COMMENT 'Version for this Note',
	RevisionId int NULL COMMENT 'Optional Revision for this Note -- for notes specific to an Revision',
	BibleId int NULL COMMENT 'Optional Bible for this Note -- for notes specific to a Bible',
	CanonId int NULL COMMENT 'Optional Canon for this Note -- for notes that apply to the Canon as a whole',
	BookId int NULL COMMENT 'Optional Book for this Note -- for notes that apply to the Book as a whole',
	ChapterId int NULL COMMENT 'Optional Chapter for this Note -- for notes that apply to the Chapter as a whole',
	VerseId int NULL COMMENT 'Optional Verse for this Note -- for notes that apply to the Verse. Use BibleVerses.Notes for short notes',
	Note text NOT NULL COMMENT 'Content of the Note',
	Label varchar(64) CHARACTER SET ascii NULL COMMENT 'Optional Label for the Note',
	Ranking int NOT NULL DEFAULT 0 COMMENT 'Weight (Descending Sort Order) of the Note',
	PRIMARY KEY (Id),
	CONSTRAINT FK_VersionNotes_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_VersionNotes_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_VersionNotes_Bibles FOREIGN KEY (BibleId) REFERENCES Bibles (Id),
	CONSTRAINT FK_VersionNotes_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_VersionNotes_Books FOREIGN KEY (CanonId) REFERENCES Books (Id),
	CONSTRAINT FK_VersionNotes_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters (Id),
	CONSTRAINT FK_VersionNotes_Verses FOREIGN KEY (VerseId) REFERENCES Verses (Id)
);
