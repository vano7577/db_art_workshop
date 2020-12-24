# Subject area "art workshop"
## Entity Relationship diagram №1 #
![](http://www.plantuml.com/plantuml/proxy?cache=yes&src=https://raw.githubusercontent.com/vano7577/db_art_workshop/master/ER-2.puml)

## Datalogical model
![.](https://github.com/vano7577/db_art_workshop/blob/main/painting.png)
integrity constraints:

abbreviation  | integrity constraints
------------- | -------------
PK | primary key
FK | foreign key
UN | unique
NN | NOT NULL
CH | CHECK
1* | > '1900-01-01'
2* | ~ '^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$'
3* | >0
4* | BETWEEN 0 AND 100
5* |  char_length(contact_phone_num) =12
6* | >=0

## Physical data model
![.](https://github.com/vano7577/db_art_workshop/blob/main/art_workshop.png)
