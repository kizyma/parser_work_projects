# parser_work_projects
create an "output" folder in the same folder with the parser itself.
launch via ruby txt-scraper.rb log_in_cookie id_from id_to
----------------------------------
v.0.2 changes
-user ID was added(as a first argument, now launch via ruby txt-scraper.rb ID PHPSESSID FROM TO)

-cookie and user validation

-empty ticket validation (previously crashed, when it could not find clients email - all tickets up to 16000 are like that, 251761 is like that as well)

-validation before downloading the file (it checkts whether it is msinfo32, it excludes the non-english versions of the file
TO DO:
Add validation for the new languages
----------------------------------
v.0.2.1 changes
- added support of German, Spanish and French language
- minor speed improvements (in the previous version, there was an issue with time-out and each URL took additional second to be processed)

