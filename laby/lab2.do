********************************************************************************
*  ZAAWANSOWANA EKONOMETRIA 2025-26 LAB 2 : Szeregi czasowe
*  Kurs: Zaawansowana Ekonometria

********************************************************************************


clear all
set more off


********************************************************************************
*  CZĘŚĆ 1: Podstawy pracy z szeregami czasowymi
********************************************************************************

* --- Wczytanie danych ---
* Używamy wbudowanego zbioru danych Staty z danymi makro dla USA
* (kwartalny PKB, konsumpcja, inwestycje, itd.)

sysuse gnp96, clear

* Zapoznajcie się ze zbiorem danych:
describe
summarize
list in 1/8


* --- Deklaracja struktury czasowej ---
* Stata wymaga jawnego wskazania zmiennej czasowej komendą tsset.
* Bez tego komendy ts (L., D., F., itp.) nie będą działać.

tsset date

* Po tsset Stata wie, że obserwacje są uporządkowane w czasie
* i może automatycznie tworzyć opóźnienia, różnice, itp.


* --- Operatory czasowe ---
* L.  = lag (opóźnienie)
* L2. = lag drugiego rzędu
* D.  = pierwsza różnica (x_t - x_{t-1})
* D2. = druga różnica
* F.  = lead (wartość przyszła)
* S.  = sezonowa różnica

* Zobaczmy jak działają:
gen gnp_lag1 = L.gnp96
gen gnp_lag2 = L2.gnp96
gen gnp_diff = D.gnp96

list date gnp96 gnp_lag1 gnp_lag2 gnp_diff in 1/8


* --- Wykres szeregu czasowego ---
tsline gnp96, title("Realny PKB USA (mld USD, ceny 1996)") ///
    ytitle("PKB") xtitle("") name(g_pkb, replace)

* PKB wyraźnie rośnie w czasie –> szereg jest niestacjonarny.
* Sprawdźmy różnicę:

tsline D.gnp96, title("Pierwsza różnica realnego PKB") ///
    ytitle("Δ PKB") xtitle("") name(g_dpkb, replace)

* KOMENTARZ: Δ PKB wygląda na stacjonarny
* Teraz sprawdźmy, czy te wnioski są potwierdzone przez testy statysczne

* --- Test stacjonarności ---
* Test Dickeya-Fullera:
dfuller gnp96
* wniosek: zmienna jest NIEstacjonarna (tak jak mogliśmy sądzić po wykresie)

* Teraz Δ PKB:
* Test Dickeya-Fullera:
dfuller D.gnp96
* wniosek: zmienna jest stacjonarna (tak jak mogliśmy sądzić po wykresie)


* Podstawowa wersja testu DF zakłada, że reszty nie są autokorelowane.
* Jeśli są — test daje błędne wyniki. Dlatego stosujemy wersję
* rozszerzoną (Augmented Dickey Fuller - ADF), która dodaje opóźnienia Δy jako kontrolki,
* żeby "wyczyścić" autokorelację reszt. Jako, że są to dane kwartalne, 
* to użyjemy 4 opóźnień (reguła kciuka), ale formalnie będzie badać strukturę 
* opóźnień w następnej sekcji.
dfuller D.gnp96, lags(4)

* Porównajcie statystyki testowe obu wersji — jeśli się wyraźnie
* różnią, to znak że autokorelacja miała znaczenie
* i wersja rozszerzona jest właściwsza.


* --- Autokorelacja reszt ---
* Estymujemy prostą regresję Δ PKB na swoim opóźnieniu czyli ΔPKB_t na ΔPKB_t-1:
regress D.gnp96 LD.gnp96

* Test Breuscha-Godfreya na autokorelację reszt:
* H0: brak autokorelacji do opóźnienia k
estat bgodfrey, lags(1 2 4)

* Jeśli p-wartość < 0.05, odrzucamy H0 → reszty są autokorelowane.
* Możemy próbować dodawać kolejne opóźnienia (np. AR(2) itd.),
* aż reszty będą czyste. Ale to zużywa stopnie swobody.
* ARIMA oferuje bardziej oszczędne rozwiązanie — komponent MA
* potrafi wychwycić strukturę autokorelacji reszt za pomocą
* jednego-dwóch parametrów zamiast wielu dodatkowych lagów.


* --- Funkcja autokorelacji (ACF) i cząstkowa autokorelacja (PACF) ---
* ac  – rysuje ACF
* pac – rysuje PACF

ac gnp96, lags(20) title("ACF: PKB") name(g_acf_level, replace)
pac gnp96, lags(20) title("PACF: PKB") name(g_pacf_level, replace)
* ACF opada bardzo powoli → typowy sygnał niestacjonarności.

* Teraz ACF i PACF dla pierwszej różnicy:
ac D.gnp96, lags(20) title("ACF: Δ PKB") name(g_acf_diff, replace)
pac D.gnp96, lags(20) title("PACF: Δ PKB") name(g_pacf_diff, replace)

* ============================================================================
*  ZADANIE 1:
*
*  a) Na podstawie powższych wykresów ACF i PACF dla D.gnp96 spróbujcie wstępnie
*     zidentyfikować rząd modelu ARMA dla ΔPKB.
*
*     Przypomnienie reguł identyfikacji:
*       - ACF ucina się po q opóźnieniach, PACF wygasa → MA(q)
*       - PACF ucina się po p opóźnieniach, ACF wygasa → AR(p)
*       - Oba wygasają → ARMA(p,q)
* ============================================================================




********************************************************************************
*  CZĘŚĆ 2: Estymacja modeli ARIMA
********************************************************************************

* --- Model ARIMA ---
* Składnia: arima zmienna, arima(p, d, q)
*   p = rząd AR
*   d = rząd różnicowania
*   q = rząd MA

* Zacznijmy od prostego modelu ARIMA(1,1,0) — czyli AR(1) na pierwszej różnicy:
arima gnp96, arima(1,1,0)

* Interpretacja wyników:
*   - ar L1. = współczynnik autoregresji pierwszego rzędu
*   - _cons  = stała (dryf)
*   - sigma  = odchylenie standardowe reszt


* --- Porównanie modeli za pomocą kryteriów informacyjnych ---
* Estymujemy kilka modeli i porównujemy AIC/BIC

quietly arima gnp96, arima(1,1,0)
estimates store m_110

quietly arima gnp96, arima(0,1,1)
estimates store m_011

quietly arima gnp96, arima(1,1,1)
estimates store m_111

quietly arima gnp96, arima(2,1,0)
estimates store m_210

quietly arima gnp96, arima(2,1,1)
estimates store m_211

* Porównanie:
estimates stats m_110 m_011 m_111 m_210 m_211


* ============================================================================
*  ZADANIE 2:
*
*  a) Na podstawie tabeli z kryteriami informacyjnymi wybierzcie
*     najlepszy model. Zapiszcie jego specyfikację.
*
*  b) Wyestymujcie wybrany model jeszcze raz i przeanalizujcie wyniki.
*     Czy wszystkie współczynniki są istotne statystycznie?
*
*  c) Dodajcie do porównania model ARIMA(2,1,2) — ten sugerowany
*     przez identyfikację ACF/PACF. Czy poprawia dopasowanie?
*     Czy warto zwiększać liczbę parametrów?
* ============================================================================

* Miejsce na rozwiązanie:









********************************************************************************
*  CZĘŚĆ 3: Diagnostyka i prognozowanie
********************************************************************************

* --- Estymacja wybranego modelu (przykładowo ARIMA(1,1,1)) ---
arima gnp96, arima(1,1,1)

* --- Diagnostyka reszt ---
predict resid, residuals

* Kolejny test na autokorelację reszt:
* H0: brak autokorelacji do opóźnienia k t.z.n. jest nieistotna
* Chcemy NIE odrzucić H0 → reszty zachowują się jak biały szum
corrgram resid, lags(12)
* KOMENTARZ: wszystko wygląda dobrze, nie możemy odrzucić żadnej H0, 
* czyli wszystkie autokorelacje sa nieistotne

* ACF reszt – wizualna kontrola:
ac resid, lags(20) title("ACF reszt modelu ARIMA(1,1,1)") ///
    name(g_acf_resid, replace)
* KOMENTARZ: wszystkie autokorelacje nieistotne


* --- Prognozowanie ---
* Rozszerzamy zbiór o 8 przyszłych kwartałów:
tsappend, add(8)

* Prognoza dynamiczna — od pierwszego nowego kwartału model
* używa własnych prognoz zamiast danych:
predict gnp_forecast, dynamic(tq(2002q1)) y

* Wykres:
twoway (tsline gnp96, lcolor(black)) ///
       (tsline gnp_forecast, lcolor(blue) lpattern(dash)) ///
       if tin(1998q1,), ///
    title("PKB: wartości rzeczywiste i prognoza") ///
    legend(label(1 "Rzeczywiste") label(2 "Prognoza")) ///
    name(g_forecast, replace)


* ============================================================================
*  ZADANIE 3:
*
*  a) Wyobraźcie sobie, że korelogram reszt pokazuje istotną
*     autokorelację na pierwszych lagach (1, 2, 3).
*     Co by to oznaczało dla naszego modelu? Co byście zrobili?
*
*  b) Porównajcie wizualnie prognozę z rzeczywistymi danymi.
*     Czy model dobrze ekstrapoluje trend?
* ============================================================================




