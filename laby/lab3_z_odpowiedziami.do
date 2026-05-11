/* ZAAWANSOWANA EKONOMETRIA gr 101 LAB 3 */

bcuse mroz

*Naszą zmienną zależną będzie inlf  (married women in labour force, 1=yes 0=no)

summarize 
tab inlf
inspect inlf 

*325 kobiet w próbie nie jest aktywnych na rynku pracy, a 428 kobiet jest aktywnych 

*LPM

reg inlf age educ kidslt6 kidsge6 hushrs
predict p_lpm, xb

sort p_lpm
list p_lpm in 1/10
list p_lpm in 743/753 /*list p_lpm in -10/1*/

*PROBIT 

probit inlf age educ kidslt6 kidsge6 hushrs
predict p_probit, pr 

sort p_probit
list p_probit in 1/10
list p_probit in 743/753 

/*
predict l_probit, xb
gen pr_not_l_probit = normal(l_probit)
*/

margins, dydx(*) atmeans
margins, dydx(*) 

/*
display -.0391117*25 + .1251945*5  -.8975522*1 -.0473848*1 -.0002062*300 + 1.055383
display normal(-.303234)

*Osoba o takich samych charakterystykach ale rok starsza (26 lat)

display -.0391117*26 + .1251945*5  -.8975522*1 -.0473848*1 -.0002062*300 + 1.055383
display normal(-.3423457)

display -.303234 -.3423457
*/


*search spost9_ado - jeżeli nie działa komenda poniżej to należy zainstalować paczkę
fitstat, sav(r2_1)

*LOGIT  

logit inlf age educ kidslt6 kidsge6 hushrs
predict p_logit, pr 

sort p_logit
list p_logit in 1/10
list p_logit in 743/753 

/*
predict l_logit, xb
gen pr_not_l_logit = logistic(l_logit)
*/

margins, dydx(*) atmeans
margins, dydx(*) 

*ilorazy szans 
logit, or 
logistic inlf age educ kidslt6 kidsge6 hushrs

*jak zmienić punkt odcięcia p*

estat classification /*defaultowo 0.5*/
estat classification, cutoff(0.25)


/* ZADANIE 1 (logit) */
*Dane z: https://www.kaggle.com/datasets/amanace/student-admission-dataset 

*Wczytaj dane z pliku student_admission.csv

*1A. Ilu studentów zostało przyjętych na studia? Ilu znajduje się na liście oczekujących?

tab admission_status

*zaakceptowanych zostało 81 osób, 88 osób znajduje się na liście oczekujących 

*1B. Skonstruuj nową zmienną zerojedynkową, która przyjmuje wartość 1 jeżeli dany kandydat został przyjęty na studia w pierwszej turze oraz 0 jeżeli nie (tj jest na liście oczeujących lub odrzucony). 

gen accepted = 1 if admission_status=="Accepted"
replace accepted = 0 if admission_status!="Accepted"

tab accepted

*1C. Oszacuj model logitowy w którym wyjaśnisz prawdopodobieństwo przyjęcia na studia w pierwszej turze za pomocą średniej kandydata (GPA), wyniku egzaminu kompetencji (SAT) oraz liczby zajęć dodatkowych (Extracurricular_Activities). Zinterpretuj otrzymane wyniki. Czy zmienne są łącznie istotne?

logit accepted gpa sat_score extracurricular_activities

*Zmienne w modelu są łącznie istotne na poziomie istotności 5% (p-value = 0.0137). 
*Istotną zmienną w modelu jest sat_score (p-value=0.004) - inne zmienne nie są istotne. 
*Zatem interpretujemy znak parametru przy sat_score jako: wyższy wynik na teście sat jest związany z wyższym prawdopodobieństwem przyjęcia na studia w pierwszym terminie. 

*1D. Policz ilorazy szans. Zinterpretuj iloraz szans dla zmiennej sat_score. 

logit, or

*iloraz szans dla zmiennej sat_score (ciągła zmienna): 1.002, zatem osoby z wynikiem z testu sat o 1 punkt (jedną jednostkę) wyższym niż średnia w próbie maja o 0.2% wyższą szansę przyjęcia na studia w pierwszej turze. Mimo że różnica jest istotna, to nie jest duża.

*1E. Zinterpretuj R^2 McFaddena i R^2 McKelvey i Zavoiny. 

fitstat, sav(r2_1)

*Nie interpretujemy wielkości R^2 McFaddena. R^2 McKelvey i Zavoiny = ile procent zmienności zmiennej ukrytej zostało wyjaśnione przez model, gdybyśmy obserwowali tą zmienną

*1F. W jaki sposób mozna rozszerzyć model, aby sprawdzić czy proces selekcji przyszłych studentów jest obiektywny? Zaproponuj jakie zmienne warto dodać i co przetestować. 

*Można dodać zmienne informujące o płci albo wieku kandydata i przetestować, czy istotnie wpływają na prawdopodobieństwo przyjęcia na studia. 


/* ZADANIE 2 (LPM, wrażliwość, specyficzność) */

bcuse mlb1, clear

*Szacujemy prawdopodobieństwo, że zawodnik znajdzie się wśród 10% najlepiej zarabiających bejsbolistów (dane z 1993) roku

*2A. Skonstruuj nową zmienną top10, która przjmie wartość 1 jeżeli wynagrodzenie znajduje się w top 10
summarize salary, detail

gen top10 = 0
replace top10 = 1 if salary>=3500000
tab top10 /*faktycznie zgadza się ok 10%*/

*2B. Oszacuj LMP. Jako zmienne niezależne wykorzystaj: liczbę lat gry w major league (years), liczbę rozegranych gier (games), informację o tym, czy zawodnik gra w national league (nl) oraz liczbę lat jako all-star (yrsallst)

reg top10 years games nl yrsallst

*2C. Oszacuj model logitowy i zinterpretuj efekty cząstkowe policzone dla średnich poziomów. Policz ilorazy szans. Porównaj wyniki z LMP. 

logit top10 years games nl yrsallst
margins, dydx(*) atmeans

*years = -0.034, dodatkowy rok gry w major league jest związany ze spadkiem prawdopodobieństwa bycia wśród 10% najlepiej zarabiających zawodników o 3.4 punkty procentowe, przy innych charakterystykach na poziomie średnich
*games = 0.0003, wzrost liczby rozegranych gier w karierze o 1, jest związany z wzrostem prawdopodobieństwa bycia wśród 10% najlepiej zarabiających zawodników o 0.03 punkta procentowego, przy innych charakterystykach na poziomie średnich 
*yrsallst = 0.017, dodatkowy rok jako zawodnik all-star, jest związany ze wzrostem prawdopodobieństwa bycia wśród 10% najlepiej zarabiających zawodników o 1.7 punkta procentowego, przy innych charakterystykach na poziomie średnich

logit, or

*years = 0.56, dodatkowy rok gry w major league jest związany ze spadkiem szansy bycia wśród 10% najlepiej zarabiających zawodników o 44% (z każdym kolejnym rokiem przemnażamy szansę przez 0,56)
*games = 1.004, dodatkowa rozegrana gra w karierze jest związana ze wzrostem szansy bycia wśród 10% najlepiej zarabiających zawodników o 0.4%
*yrsallst = 1.33, dodatkowy rok jako zawodnik all-star jest związany ze wzrostem szansy bycia wśród 10% najlepiej zarabiających zawodników o 33%

*2D. Oszacuj model probitowy. Porównaj wyniki z logitem - odnieś się do parametrów oraz efektów cząstkowych. 

probit top10 years games nl yrsallst
margins, dydx(*) atmeans

*Znaki przy poszczególnych parametrach są takie same. Zauważyć można różnice w wielkości efektów cząstkowych, ale nie są one znaczące. 

*2E. Policz wrażliwość modelu 2C. 
logit top10 years games nl yrsallst
estat classification

display 6/37
*wrażliwość = 16.22%, co oznacza że 16% sukcesów zostało poprawnie zaklasyfikowanych jako sukcesy

*2F. Policz specyficzność modelu 2C. 

display 308/316

*specyficzność = 97.47%, co oznacza że ponad 97% porażek zostało poprawnie zaklasyfikowanych jako porażki 

*2F. Czy zaproponowany model jest przydatny do analizowanego problemu? Skomentuj powołując się na miary dopasowania (np. R^2 liczebnościowe). 

fitstat, sav(r2_1)
*Nie. 
*R^2 liczebnościowe jest równe 0.89 ale skorygowane R^2 liczebnościowe jest nawet ujemne. 

/* ZADANIE 3 (probit) */

*Wczytaj dane z pliku Bank_Personal_Loan_Modelling.csv

*3A. Oszacuj model probitowy, w którym wyjaśnisz prawdopodobieństwo, że dany klient przyjął zaproponowaną ofertę kredytu (personalloan, 1=przyjął 0=nie przyjął). Jako zmienne niezależne wykorzystaj wiek (age),  dochód w tysiącach $ (income), liczbę członków rodziny (family), poziom wykształcenia (education, 1=średnie 2=wyższe 3=profesjonalne zawodowe), oraz informację o tym, czy dany klinet posiada kartę kredytoą w banku (creditcard). 

probit personalloan age income family i.education creditcard

*3B. Czy zmienne w modelu są łącznie istotne?

*Tak, prob>chi2 =0.0000

*3C. Zinterpretuj wpływ dochodu na prawdopodobieństwo przyjęcia oferty kredytu.

*Dodatni znak przy oszacowaniu parametru - wzrost dochodu jest związany ze wzrostem prawdopodobieństwa przyjęcia oferty kredytu. 

margins, dydx(*) atmeans

*wzrost dochodu o 1 jednostkę (o 1000$) jest związany ze wzrostem prawdopodobieństwa przyjęcia kredytu o 1.3 punkta procentowego, przy pozostałych charakterystykach na poziomie średnich 

*3D. Zinterpretuj efekt cząstkowy dla zmiennej education = 2. 

*prawdopodobieństwo przyjęcia oferty kredytu dla osoby z wyższym wykształceniem (educ=2) jest o 48.5 punkta procentowego wyższe niż dla osoby o wykształceniu podstawowym (poziom bazowy), o pozostałych charakterystykach na poziomie średnich 
