/*	ZAAWANSOWANA EKONOMETRIA gr 101 LAB 3 */

bcuse mroz

*Naszą zmienną zależną będzie inlf  (married women in labour force, 1=yes 0=no)

summarize 
tab inlf
inspect inlf 

*325 kobiet w próbie nie jest aktywnych na rynku pracy, a 428 kobiet jest aktywnych 

*Linear Probability Model

reg inlf age educ kidslt6 kidsge6 hushrs
predict p_lpm, xb

* Widzimy, ze model liniowy przewiduje wartosci <0 oraz >1
* Jest to problem
sort p_lpm
list p_lpm in 1/10
list p_lpm in 743/753 /*list p_lpm in -10/1*/

*PROBIT 

probit inlf age educ kidslt6 kidsge6 hushrs
predict p_probit, pr 

* Widzimy, ze model probit przewiduje wartosci tylko w interwale (0, 1)
sort p_probit
list p_probit in 1/10
list p_probit in 743/753 

/*
predict l_probit, xb
gen pr_not_l_probit = normal(l_probit)
*/



/*
Average Marginal Effects (AME) and Marginal Effects at the Mean (MEM) are methods for interpreting nonlinear models (e.g., logit, probit). AME calculates the marginal effect for every observation and averages them, representing the average effect across the entire population. MEM calculates the marginal effect by setting all variables to their means, representing the effect for an "average" person
*/

* Average Marginal Effect (AME)
margins, dydx(*)

* Marginal Effects at the Mean (MEM)
margins, dydx(*) atmeans


*search spost9_ado
fitstat, sav(r2_1)

*LOGIT  

logit inlf age educ kidslt6 kidsge6 hushrs
predict p_logit, pr 

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

estat classification
estat classification, cutoff(0.25)


/* ZADANIE 1 (logit) */
*Dane z: https://www.kaggle.com/datasets/amanace/student-admission-dataset 

*Wczytaj dane z pliku student_admission.csv

*1A. Ilu studentów zostało przyjętych na studia? Ilu znajduje się na liście oczekujących?

*1B. Skonstruuj nową zmienną zerojedynkową, która przyjmuje wartość 1 jeżeli dany kandydat został przyjęty na studia w pierwszej turze oraz 0 jeżeli nie (tj jest na liście oczeujących lub odrzucony). 

*1C. Oszacuj model logitowy w którym wyjaśnisz prawdopodobieństwo przyjęcia na studia w pierwszej turze za pomocą średniej kandydata (GPA), wyniku egzaminu kompetencji (SAT) oraz liczby zajęć dodatkowych (Extracurricular_Activities). Zinterpretuj otrzymane wyniki. Czy zmienne są łącznie istotne?

*1D. Policz ilorazy szans. Zinterpretuj iloraz szans dla zmiennej sat_score. 

*1E. Zinterpretuj R^2 McFaddena i R^2 McKelvey i Zavoiny. 

*1F. W jaki sposób mozna rozszerzyć model, aby sprawdzić czy proces selekcji przyszłych studentów jest obiektywny? Zaproponuj jakie zmienne warto dodać i co przetestować. 


/* ZADANIE 2 (LPM, wrażliwość, specyficzność) */

bcuse mlb1, clear

*Szacujemy prawdopodobieństwo, że zawodnik znajdzie się wśród 10% najlepiej zarabiających bejsbolistów (dane z 1993) roku

*2A. Skonstruuj nową zmienną top10, która przjmie wartość 1 jeżeli wynagrodzenie znajduje się w top 10

*2B. Oszacuj LMP. Jako zmienne niezależne wykorzystaj: liczbę lat gry w major league (years), liczbę rozegranych gier (games), informację o tym, czy zawodnik gra w national league (nl) oraz liczbę lat jako all-star (yrsallst)

*2C. Oszacuj model logitowy i zinterpretuj efekty cząstkowe policzone dla śrenich poziomów. Policz ilorazy szans. Porównaj wyniki z LMP. 

*2D. Oszacuj model probitowy. Porównaj wyniki z logitem - odnieś się do parametrów oraz efektów cząstkowych. 

*2E. Policz wrażliwość modelu 2C. 

*2F. Policz specyficzność modelu 2C. 

*2F. Czy zaproponowany model jest przydatny do analizowanego problemu? Skomentuj powołując się na miary dopasowania (np. R^2 liczebnościowe). 

/* ZADANIE 3 (probit) */

*Wczytaj dane z pliku Bank_Personal_Loan_Modelling.csv

*3A. Oszacuj model probitowy, w którym wyjaśnisz prawdopodobieństwo, że dany klient przyjął zaproponowaną ofertę kedytu (personalloan, 1=przyjął 0=nie przyjął). Jako zmienne niezależne wykorzystaj wiek (age),  dochód w tysiącach $ (income), liczbę członków rodziny (family), poziom wykształcenia (education, 1=średnie 2=wyższe 3=profesjonalne zawodowe), oraz informację o tym, czy dany klinet posiada kartę kredytoą w banku (creditcard). 

*3B. Czy zmienne w modelu są łącznie istotne?

*3C. Zinterpretuj wpływ dochodu na prawdopodobieństwo przyjęcia oferty kredytu.

margins, dydx(*) atmeans

*3D. Zinterpretuj efekt cząstkowy dla zmiennej education = 2. 

