/******************************************************************************/

/******************* ZAAWANSOWANA EKONOMETRIA 2025-26 LAB 1 *******************/

/******************************************************************************/
							

		
/******************************************************************************/
/******************* PODSTAOWE FUNKCJE -- DEMONSTRACJA ************************/
/******************************************************************************/
* Powtórzenie podstawowych funkcji Staty: https://www.youtube.com/watch?v=gdnDkjoPJTM&t=4s
						
* aby wykonać komendę użyj crtl+D
display 2+2
display 2^3
di (4+5)/3^2 /*możemy użyć skrótu di */
di ((4+5)/3)^2


/*
Żeby zapisać wszystkie wyniki, które otrzymamy w trakcie naszej analizy możemy
wykorzystać logi - należy podać nazwę pliku, w którym nadpisywane będą wszystkie 
wykonane operacje (teraz lab1). Po zakończonej analizie zamykamy również log,
który zapisuje się automatycznie.
*/
log using lab1, text replace 


* wczytamy wbudowany zbiór danych odnośnie samochodów, żeby przetestować podstatowe komendy
sysuse auto, clear

* wstepna analiza danaych
summarize price gear_ratio, detail
browse if missing(rep78)
help summarize

*narysujemy histogram cen
hist price

*stworzymy zmienną lprize, która będzie równa logarytmowi naturalnemu ceny
generate lprice = log(price)
hist lprice, normal

*stworzymy zmienną zero-jedynkową, która będzie informowała o tym czy cena samochodu jest powyżej średniej czy poniżej średniej
gen price_above = 0 
egen M = mean(price)
replace price_above = 1 if price > M

* usuwamy obserwacje dla aut które mają efektywnosc pojazdu większy niż 30 mil na galon
drop if mpg > 30

* zmieniamy nazwę zmiennej displacement na engine_displacement
rename displacement engine_displacement

* policzymy ile aut było naprawianych do 1978 roku dokładnie 3 razy a ile przynajniej raz 
count if rep78 == 3
count if rep78 > 0

* stworzymy prosta regresje logarytmu ceny na mpg, foreign, gear_ratio
regress lprice mpg foreign gear_ratio

predict lpricehat, xb /*wartości dopasowane*/
predict reszty, r /*reszty*/
tabstat lprice lpricehat reszty




/******************************************************************************/
/****************************** ZADANIE 1  ************************************/
/******************************************************************************/

/* Dane zostały zebrane wśród kobiet w Botswanie w 1988 roku
  1. mnthborn                 month woman born
  2. yearborn                 year woman born
  3. age                      age in years
  4. electric                 =1 if has electricity
  5. radio                    =1 if has radio
  6. tv                       =1 if has tv
  7. bicycle                  =1 if has bicycle
  8. educ                     years of education
  9. ceb                      children ever born
 10. agefbrth                 age at first birth
 11. children                 number of living children
 12. knowmeth                 =1 if know about birth control
 13. usemeth                  =1 if ever use birth control
 14. monthfm                  month of first marriage
 15. yearfm                   year of first marriage
 16. agefm                    age at first marriage
 17. idlnchld                 'ideal' number of children
 18. heduc                    husband's years of education
 19. agesq                    age^2
 20. urban                    =1 if live in urban area
 21. urbeduc                  urban*educ
 22. spirit                   =1 if religion == spirit
 23. protest                  =1 if religion == protestant
 24. catholic                 =1 if religion == catholic
 25. frsthalf                 =1 if mnthborn <= 6
 26. educ0                    =1 if educ == 0
 27. evermarr                 =1 if ever married
 */

* wczytamy dane z Wooldrige'a (zainstalujemy komende bcuse, ktora pozwala na wczytywanie takich danych)
ssc install bcuse
bcuse fertil2, clear

* 1A Wskaż najniższą i najwyższą liczbę posiadanych dzieci w próbie (children). Jaka jest średnia liczba dzieci dla kobiet w próbie? Ile kobiet posiada liczbę dzieci równą medianie w danych?
summarize children, detail
tabstat children, stat(min max mean median)
count if children==2
*Najniższa liczba dzieci to 0 a najwyższa 13. Średnia liczba dzieci to 2.27. Mediana jest równa 2 - 696 kobiet w próbie ma dwoje dzieci. 


* 1B Jaki procent kobiet ma dostęp do elektryczności w domu?
count if electric==1
di 611/_N
*14% kobiet ma dostep do elektryczności

/*1C Policz średnią liczbę dzieci osobno dla kobiet które posiadają dostęp do elektryczności w domu i dla tych, które nie posiadają dostępu.
Skomentuj wyniki. Przetestuj czy średnie w tych dwóch populacjach są sobie równe za pomocą prostej (jednozmiennowej) regresji. 
*/
summ children if electric==1
summ children if electric==0
reg children electric
* Różnica między średnimi jest statystycznie istotna.

* 1D Czy na podstawie wyników z podpunktu 2C można stwierdzić, że dostęp do elektryczności "powoduje" spadek liczby posiadanych dzieci?
* ODPOWIEDŹ: NIE. Możemy powiedzieć jedynie, że różnica w średniej liczbie dzieci w tych dwóch grupach jest statystycznie istotna. Nasz prosta regresa nie uwzględnia innych kluczowych zmiennych, które są skorelowane z elektrycznością.


* 1E Oszacuj model w którym wyjaśnisz liczbę dzieci i uwzględnisz dostęp do elekstryczności, wiek, wiek podniesiony do kwadratu, zmienną urban, educ, oraz informację o wyznaniu religijnym danej kobiety. Skomentuj wpływ zmiennej electric w porównaniu z podpunktem 1C.
reg children electric age agesq urban educ spirit protest catholic
* Zmienna electric ma mniejszy wpływ niż w podpunktcie 1C, ponieważ uwzględniliśmy inne zmienne, które są skorelowane ze zmienną electric. Nasza wcześniejsza regresja miała "ommited variable bias".


/******************************************************************************/
/****************************** ZADANIE 2  ************************************/
/******************************************************************************/

* wczytamy dane z ze strony internetowej http://fmwww.bc.edu/ec-p/data/wooldridge/datasets.list.html
/*  
  1. wage                     monthly earnings
  2. hours                    average weekly hours
  3. IQ                       IQ score
  4. KWW                      knowledge of world work score
  5. educ                     years of education
  6. exper                    years of work experience
  7. tenure                   years with current employer
  8. age                      age in years
  9. married                  =1 if married
 10. black                    =1 if black
 11. south                    =1 if live in south
 12. urban                    =1 if live in SMSA
 13. sibs                     number of siblings
 14. brthord                  birth order
 15. meduc                    mother's education
 16. feduc                    father's education
 17. lwage                    natural log of wage*/

*ssc install bcuse 
bcuse wage2, clear


/*2A Oszacuj model w którym logarytm wysokości miesięcznych zarobków wyjaśniany będzie za pomocą zmiennych educ, exper, tenure, married, black, south, i urban.*/
reg lwage educ exper tenure married black south urban


/*2B Ceteris paribus, jaka jest różnica w miesięcznych zarobkach między osobami czarnoskórymi i tymi które nie są czarnoskóre? Czy ta różnica jest statystycznie istotna?*/
di exp(_b[black]) - 1
* Osoby czarnoskóre zarabiają średnio o 17,2% mniej niż osoby które nie są czarnoskóre. Różnica jest statystycznie istotna (zmienna black).


/*2C Skonstruuj nową zmienną exper2 = exper^2 i oszacuj regresję z podpunktu 2A z dodatkową zmienną exper2. Skomentuj wartość-p z tabeli odnośnie istotność zmiennej exper w porównaniu z regresją z 2A.
Na poziomie istotności 1% przetestuj hipotezę zerową o tym, że zmienne exper i exper2 są łącznie nieistotne. Skomentuj wyniki.*/
gen exper2 = exper^2
reg lwage educ exper tenure married black south urban exper2
* Zmienna exper przesstała być istotna na podstawie testu t. Zmienna exper2 również jest nieistotna.
test exper2 exper
* Odrzucamy H0, że zmiene exper i exper2 są łącznie nieisotne na poziomie 1%.
* Dlaczego tak się dzieje? Zmienne exper i exper2 są skorelowane co zwiększa ich błędy standardowe (zaczyna występować współliniowość). Test-t przestaje być dobrą miarą istotności. 
* Test F nie ma tego problemu.


/*2D Zaproponuj rozszerzenie modelu z punktu 2A, w którym uwzględnisz fakt, że liczba lat edukacji może zależeć od rasy oraz przetestuj czy taka zależność zachodzi*/
reg lwage educ exper tenure married black south urban c.educ#i.black
* Interakcja nie jest statystycznie istotna, p-value=0.263. To oznacza, że wpływ edukacji na zarobki nie zależy od rasy, jeżeli kontrolujemy zmienne exper, tenure, married, south i urban. 


/*2E Zaproponuj rozszerzenie modelu z punktu 2A, w którym uwzględnisz fakt, że zarobki mogą się różnić w następujących czterech grupach: 
(i) czarnoskórych po ślubie
(ii) nie-czarnoskórych po ślubie
(iii) czarnoskórych bez ślubu
(iv) nie-czarnoskórych bez ślubu */
reg lwage educ exper tenure married##black south urban 


/*2F Jaka jest oczekiwana różnica w miesięcznych zarobkach między osobami czarnoskórymi, które są po ślubie a osobami nie-czarnoskórymi, które są po ślubie?*/
*
di -.2408201 + .0613538
* Odpowiedz: -0.1794 i.e. osoby czarnoskóre po ślubie zarabiają średnio 17,9% mniej niż osoby nie-czarnoskóre po ślubie, ceteris paribus


/*2G Przeprowadź diagnostykę reszt z modelu z podpunktu 2E pod kątem homoskedastyczności or normalnośći.
Skomentuj swoje wyniki. Weź pod uwagę wielkość próby.*/
predict reszty, r
estat hettest
estat imtest, white
/*
Jeśli nie mamy normalności, to test White jest lepszy. 
W obu testach na poziomie istotności 5% nie ma podstaw do odrzucenia H0 o homoskedastyczności. 
To dobry znak dla naszej regresji.
*/

hist reszty, normal
sktest reszty 
/*odrzucamy H0, błedy losowe nie mają rozkładu normalnego. 
Testowanie hipotez może być niepoprawne w małych próbach, ale tutaj  liczebność próby (n okolo 900) jest duża, 
dlatego na mocy centralnego twierdzenia granicznego brak normalności reszt NIE powinien istotnie wpływać na własności estymatorów ani na wnioskowanie statystyczne.	
*/


/******************************************************************************/
/************ METODA ZMIENNYCH INSTRUMENTALNYCH -- DEMONSTRACJA ***************/
/******************************************************************************/

bcuse wage2, clear

ivregress 2sls lwage (educ=sibs meduc)

estat endog /*Test Hausmana-Wu -> odrzucamy H0 o egzogeniczności zmiennej educ*/
estat overid /*Test Sargana -> nie możemy odrzucić H0 o łącznej egzogeniczności instrumentów*/
estat firststage /*test na istostność instrumentów w pierwszy etapie - wersja automatyczna -> odrzucamy H0 o łącznej nieistotności intrumentów */
/* Czyli instrumenty są łącznie istotne i egzogeniczne -> tzn. że spełaniają warunki na podstawie tych testów */
/*
Dodaktowe wyjaśnienie drugiej tabeli (nieobowiązkowe):
Powyższa komenda zawiera również dodaktowe wartości krytyczne Stock-Yogo: tabela druga, rząd zatutułowany: "2SLS size of nominal 5% Wald test".
Te wartości mogą być użyte do testu z naszą statystyką F. 
Dlaczego potrzebujemy dodaktowych wartości? Stock i Yogo pokazali, że tradycyjny test F może zawieść w
niektórych przypadkach i nasze poziomy istotności mogą być zaburzone. 
W tym wypadku, nasza statystyka F (=76.4333) jest wyższa, niż którakolwiek z tych wartości, 
więc możemy być raczej spokojni odrzucająć hipotezę zerową.
*/

/* Możemy też przeprowadzić ten test sami - stastytyka F jest taka sama jak wyżej*/
reg educ sibs meduc 
test sibs meduc


/******************************************************************************/
/****************************** ZADANIE 3  ************************************/
/******************************************************************************/

* 3A. Wyjaśnij dlaczego to, którym dzieckiem w rodzinie jest dana osoba (1=pierwsze dziecko, 2=drugie dziecki, itd.) może być negatywnie skorelowane z liczbą lat edukacji. Przeprowadź regresję zmiennej educ na zmiennej brthord i porównaj wyniki ze swoją intuicją. 

reg educ brthord
* ODPOWIEDŹ: Przykładowo, rodzice mogą przeznaczać więcej pieniędzy na pierwsze dziecko, a potem w miarę jak pojawiają się kolejne dzieci to zasoby dzielone są na więcej osób, ale kontunuują to co zaczęli już robić z tym pierwszym dzieckiem np. kontynuują naukę. 


* 3B. Oszacuj model dla lwage za pomocą MZI 2MNK. Wykorzystaj zmienną brthord jako instrument dla zmiennej educ. Oprócz tego, w modelu uwzględnij również wiek (age) i stan cywilny (married). Zinterpretuj parametry. 
ivregress 2sls lwage age married (educ = brthord)

* UWAGA NA PRZYBLIŻENIE LOG!
display exp(_b[educ])-1
*dodatkowy rok edukacji przyniesie oczekiwany wzrost zarobków o 13,8%, ceteris paribus
display exp(_b[age])-1
*dodatkowy rok życia przyniesie oczekiwany wzrost zarobków o 2%, ceteris paribus
display exp(_b[married])-1
*żonaci mężczyźni (dane wage2 dotyczyły mężczyzn) mają średnio o 28,2% wyższe zarobki niż nieżonaci, ceteris paribus


* 3C. Teraz przyjmij, że liczba rodzeństwa traktowana jest jako odzwierciedlenie sytuacji rodzinnej danej osoby i z tego powodu została ona włączona do modelu jako zmienna egzogeniczna. Podaj postać regresji pomocniczej i oszacuj ją - jakie warunki muszą być spełnione?
reg educ age married sibs brthord
* ewentualnie 
ivregress 2sls lwage age married sibs (educ = brthord), first /*te same wyniki w pierwszym stopniu*/
* ODPOWIEDŹ: 
*  --> ISTOTNOŚĆ: w regresji pomocniczej parametr przy zmiennej brthord jest statystycznie istotny, zatem jest związek między zmienną endogeniczną a proponowanym instrumentem
*  --> EGZOGENICZNOŚĆ: ponieważ mamy tylko jeden instrument, NIE możemy wykonać testu Sargana, który testuje łączną egzogeniczność. Musimy argumentować egzogenicznośc instrumentu teoretycznie.


* 3D. Oszacuj pełny model (oba etapy) używająć MZI 2MNK. Skomentuj wyniki i błędy standardowe oszacowań parametrów w drugim etapie.
ivregress 2sls lwage age married sibs (educ = brthord)


* 3E. Podaj współczynnik korelacji między wartościami dopasowanymi dla zmiennej educ (z regresji pomocniczej) a zmienną sibs. Jaki ma to wpływ na błędy standardowe oszacowań w regresji z podpunktu 3C?
reg educ age married sibs brthord
predict educ_hat, xb
corr educ_hat sibs
* ODPOWIEDŹ: współczynnik korelacji -0.89 wskazuje na silną negatywną korelację, w efekcie w modelu w punkcie 3D znajdują się dwie zmienne silnie skorelowane ze sobą (sibs oraz podstawione wartości dopasowane dla endogenicznej zmiennej educ) stąd błędy standardowe są duże

capture log close 









