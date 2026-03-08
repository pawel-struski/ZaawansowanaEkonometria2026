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



* 1B Jaki procent kobiet ma dostęp do elektryczności w domu?



/*1C Policz średnią liczbę dzieci osobno dla kobiet które posiadają dostęp do elektryczności w domu i dla tych, które nie posiadają dostępu.
Skomentuj wyniki. Przetestuj czy średnie w tych dwóch populacjach są sobie równe za pomocą prostej (jednozmiennowej) regresji. 
*/



* 1D Czy na podstawie wyników z podpunktu 2C można stwierdzić, że dostęp do elektryczności "powoduje" spadek liczby posiadanych dzieci?




* 1E Oszacuj model w którym wyjaśnisz liczbę dzieci i uwzględnisz dostęp do elekstryczności, wiek, wiek podniesiony do kwadratu, zmienną urban, educ, oraz informację o wyznaniu religijnym danej kobiety. Skomentuj wpływ zmiennej electric w porównaniu z podpunktem 1C.




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




/*2B Ceteris paribus, jaka jest różnica w miesięcznych zarobkach między osobami czarnoskórymi i tymi które nie są czarnoskóre? Czy ta różnica jest statystycznie istotna?*/




/*2C Skonstruuj nową zmienną exper2 = exper^2 i oszacuj regresję z podpunktu 2A z dodatkową zmienną exper2. Skomentuj wartość-p z tabeli odnośnie istotność zmiennej exper w porównaniu z regresją z 2A.
Na poziomie istotności 1% przetestuj hipotezę zerową o tym, że zmienne exper i exper2 są łącznie nieistotne. Skomentuj wyniki.*/




/*2D Zaproponuj rozszerzenie modelu z punktu 2A, w którym uwzględnisz fakt, że liczba lat edukacji może zależeć od rasy oraz przetestuj czy taka zależność zachodzi*/




/*2E Zaproponuj rozszerzenie modelu z punktu 2A, w którym uwzględnisz fakt, że zarobki mogą się różnić w następujących czterech grupach: 
(i) czarnoskórych po ślubie
(ii) nie-czarnoskórych po ślubie
(iii) czarnoskórych bez ślubu
(iv) nie-czarnoskórych bez ślubu */




/*2F Jaka jest oczekiwana różnica w miesięcznych zarobkach między osobami czarnoskórymi, które są po ślubie a osobami nie-czarnoskórymi, które są po ślubie?*/




/*2G Przeprowadź diagnostykę reszt z modelu z podpunktu 2E pod kątem homoskedastyczności or normalnośći.
Skomentuj swoje wyniki. Weź pod uwagę wielkość próby.*/





/******************************************************************************/
/************ METODA ZMIENNYCH INSTRUMENTALNYCH -- DEMONSTRACJA ***************/
/******************************************************************************/

bcuse wage2, clear

ivregress 2sls lwage (educ=sibs meduc)

estat endog /*Test Hausmana-Wu -> odrzucamy H0 o egzogeniczności zmiennej educ*/
estat overid /*Test Sargana -> nie możemy odrzucić H0 o łącznej egzogeniczności instrumentów*/
estat firststage /*test na istostność instrumentów w pierwszy etapie - wersja automatyczna -> odrzucamy H0 o łącznej nieistotności intrumentów */
/* Czyli instrumenty są łącznie istotne i egzogeniczne -> tzn. że spełaniają warunki na podstawie tych testów */


/* Możemy też przeprowadzić ten test sami - stastytyka F jest taka sama jak wyżej*/
reg educ sibs meduc 
test sibs meduc


/******************************************************************************/
/****************************** ZADANIE 3  ************************************/
/******************************************************************************/

* 3A. Wyjaśnij dlaczego to, którym dzieckiem w rodzinie jest dana osoba (1=pierwsze dziecko, 2=drugie dziecki, itd.) może być negatywnie skorelowane z liczbą lat edukacji. Przeprowadź regresję zmiennej educ na zmiennej brthord i porównaj wyniki ze swoją intuicją. 




* 3B. Oszacuj model dla lwage za pomocą MZI 2MNK. Wykorzystaj zmienną brthord jako instrument dla zmiennej educ. Oprócz tego, w modelu uwzględnij również wiek (age) i stan cywilny (married). Zinterpretuj parametry. 




* 3C. Teraz przyjmij, że liczba rodzeństwa traktowana jest jako odzwierciedlenie sytuacji rodzinnej danej osoby i z tego powodu została ona włączona do modelu jako zmienna egzogeniczna. Podaj postać regresji pomocniczej i oszacuj ją - jakie warunki muszą być spełnione?




* 3D. Oszacuj pełny model (oba etapy) używająć MZI 2MNK. Skomentuj wyniki i błędy standardowe oszacowań parametrów w drugim etapie.




* 3E. Podaj współczynnik korelacji między wartościami dopasowanymi dla zmiennej educ (z regresji pomocniczej) a zmienną sibs. Jaki ma to wpływ na błędy standardowe oszacowań w regresji z podpunktu 3C?





capture log close 









