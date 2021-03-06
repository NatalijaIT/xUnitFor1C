﻿
// { Plugin interface
Функция ОписаниеПлагина(ВозможныеТипыПлагинов) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Тип", ВозможныеТипыПлагинов.ГенераторОтчета);
	Результат.Вставить("Идентификатор", Метаданные().Имя);
	Результат.Вставить("Представление", "Отчет о тестировании в формате MXL для Yandex Allure");
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
КонецПроцедуры
// } Plugin interface

// { Report generator interface
Функция СоздатьОтчет(КонтекстЯдра, РезультатыТестирования) Экспорт
	ПостроительДереваТестов = КонтекстЯдра.Плагин("ПостроительДереваТестов");
	ЭтотОбъект.ТипыУзловДереваТестов = ПостроительДереваТестов.ТипыУзловДереваТестов;
	ЭтотОбъект.СостоянияТестов = КонтекстЯдра.СостоянияТестов;
	Отчет = СоздатьОтчетНаСервере(РезультатыТестирования);
	
	Возврат Отчет;
КонецФункции

Функция СоздатьОтчетНаСервере(РезультатыТестирования) Экспорт
	
	ИмяФайла = ПолучитьИмяВременногоФайла("xsd");
	СхемаAllure = ПолучитьМакет("СхемаAllure");
	СхемаAllure.Записать(ИмяФайла);
	
	Фабрика = СоздатьФабрикуXDTO(ИмяФайла);
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	Параметры = Новый Структура;
	Параметры.Вставить("Уровень", 1);
	
	ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, РезультатыТестирования, Фабрика, Параметры);
	
	СтрокаXML = ЗаписьXML.Закрыть();
	СтрокаXML = Allure_ПолучитьПреобразованнуюСтрокуXML(СтрокаXML);
	
	Отчет = Новый ТекстовыйДокумент;
	Отчет.ДобавитьСтроку(СтрокаXML);
	
	Возврат Отчет;
КонецФункции

Процедура ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, РезультатыТестирования, Фабрика, Параметры)

	Перем Контейнер, НаборТестов;

	ТекущийУровень = Параметры.Уровень;
	Параметры.Уровень = Параметры.Уровень + 1;
	
	Если ТекущийУровень = 1 Тогда
		
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, ЭлементКоллекции, Фабрика, Параметры);
		КонецЦикла;
		
	ИначеЕсли Параметры.Свойство("Контейнер", Контейнер) = Ложь 
			И РезультатыТестирования.Тип = ТипыУзловДереваТестов.Контейнер Тогда
		
		ТипTestSuiteResult = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "test-suite-result");
		Контейнер = Фабрика.Создать(ТипTestSuiteResult);
		Параметры.Вставить("Контейнер", Контейнер);
		
		Контейнер.name = РезультатыТестирования.Имя;
		
		Типlabels = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "labels");
		СписокМеток = Фабрика.Создать(Типlabels);
		СписокМеток.label.Добавить(Allure_ПолучитьМетку(Фабрика, "framework", "xUnitFor1C"));
		СписокМеток.label.Добавить(Allure_ПолучитьМетку(Фабрика, "language", "1С"));
		
		Контейнер.labels = СписокМеток;
		
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, ЭлементКоллекции, Фабрика, Параметры);
		КонецЦикла;
		
		Фабрика.ЗаписатьXML(ЗаписьXML, Контейнер);
		
	ИначеЕсли Параметры.Свойство("НаборТестов", НаборТестов) = Ложь 
			И РезультатыТестирования.Тип = ТипыУзловДереваТестов.Контейнер Тогда
		
		ТипTestCasesResult = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "test-cases-result");
		НаборТестов  = Фабрика.Создать(ТипTestCasesResult);
		Параметры.Вставить("НаборТестов", НаборТестов);
		
		Контейнер.test_cases = НаборТестов;
		
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, ЭлементКоллекции, Фабрика, Параметры);
		КонецЦикла;
		
	ИначеЕсли РезультатыТестирования.Тип = ТипыУзловДереваТестов.Элемент Тогда
		
		ТипTestCaseResult = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "test-case-result");
		Тест = Фабрика.Создать(ТипTestCaseResult);
		
		Тест.title = РезультатыТестирования.Представление;
		Тест.start = РезультатыТестирования.ВремяНачала;
		Тест.stop  = РезультатыТестирования.ВремяОкончания;
		Тест.status = Allure_ПолучитьСтатус(РезультатыТестирования.Состояние, СостоянияТестов);
		
		Если Тест.status = "broken" 
			ИЛИ Тест.status = "failed" Тогда
			
			СообщениеОбОшибке = УдалитьНедопустимыеСимволыXML(РезультатыТестирования.Сообщение);
			Тест.failure = Allure_ПолучитьОшибку(Фабрика, СообщениеОбОшибке);
			
			ТипParameters = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "parameters");
			НаборПараметров = Фабрика.Создать(ТипParameters);
			
			Сч = 1;
			Для Каждого ЭлементПараметр Из РезультатыТестирования.Параметры Цикл
				
				ПараметрТип = "environment-variable";
				ПараметрИмя = "Параметр " + Сч;
				ПараметрЗначение = Строка(ЭлементПараметр) + "(" + Строка(ТипЗнч(ЭлементПараметр)) + ")";
				
				Параметр = Allure_ПолучитьПараметр(Фабрика, ПараметрИмя, ПараметрЗначение, ПараметрТип);
				НаборПараметров.parameter.Добавить(Параметр);
				
				Сч = Сч + 1;
			КонецЦикла;
			
			Тест.parameters = НаборПараметров;
			
		КонецЕсли;
		
		НаборТестов.test_case.Добавить(Тест);
		
	Иначе
		
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, ЭлементКоллекции, Фабрика, Параметры);
		КонецЦикла;
	
	КонецЕсли;

КонецПроцедуры

#Если ТолстыйКлиентОбычноеПриложение Тогда
Процедура Показать(Отчет) Экспорт
	Отчет.Показать();
КонецПроцедуры
#КонецЕсли

Процедура Экспортировать(Отчет, ПолныйПутьФайла) Экспорт

	СтрокаXML = Отчет.ПолучитьТекст();
	
	ИмяФайла = ПолныйПутьФайла;
	
	// Исключаем возможность записи в UTF-8 BOM
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.ANSI);
	ЗаписьТекста.Закрыть();
	
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла,,, Истина);
	КоличествоСтрок = СтрЧислоСтрок(СтрокаXML);
	Для НомерСтроки = 1 По КоличествоСтрок Цикл
		Стр = СтрПолучитьСтроку(СтрокаXML, НомерСтроки);
		ЗаписьТекста.ЗаписатьСтроку(Стр);
	КонецЦикла;
	ЗаписьТекста.Закрыть();

КонецПроцедуры
// } Report generator interface

// { Helpers
Функция УдалитьНедопустимыеСимволыXML(Знач Результат)
	Позиция = НайтиНедопустимыеСимволыXML(Результат);
	Пока Позиция > 0 Цикл
		Результат = Лев(Результат, Позиция - 1) + Сред(Результат, Позиция + 1);
		Позиция = НайтиНедопустимыеСимволыXML(Результат, Позиция);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция Allure_ПолучитьПреобразованнуюСтрокуXML(Знач Строка)

	Строка = СтрЗаменить(Строка,"<test-suite-result","<ns2:test-suite");
	Строка = СтрЗаменить(Строка,"</test-suite-result>","</ns2:test-suite>");
	Строка = СтрЗаменить(Строка,"xmlns=""urn:model.allure.qatools.yandex.ru""","xmlns:ns2=""urn:model.allure.qatools.yandex.ru""");
	
	Возврат Строка;

КонецФункции

Функция Allure_ПолучитьМетку(Фабрика, Имя, Значение)

	Типlabel	= Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "label");
	Метка		= Фабрика.Создать(Типlabel);
	Метка.name	= Имя;
	Метка.value = Значение;
	
	Возврат Метка;

КонецФункции

Функция Allure_ПолучитьПараметр(Фабрика, Имя, Значение, Тип)

	ТипParameter 	= Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "parameter");
	Параметр 		= Фабрика.Создать(ТипParameter);
	Параметр.name  	= Имя;
	Параметр.value 	= Значение;
	Параметр.kind 	= Тип;
	
	Возврат Параметр;

КонецФункции

Функция Allure_ПолучитьОшибку(Фабрика, Знач СообщениеОбОшибке)

	ТипFailure		= Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "failure");
	Ошибка			= Фабрика.Создать(ТипFailure);
	Ошибка.message	= СообщениеОбОшибке;	
	
	Возврат Ошибка;

КонецФункции

Функция Allure_ПолучитьСтатус(Состояние, СостоянияТестов)

	Статус = "failed";
	
	Если Состояние = СостоянияТестов.Пройден Тогда
		Статус = "passed";	
	ИначеЕсли Состояние = СостоянияТестов.НеРеализован Тогда
		Статус = "canceled";
	ИначеЕсли Состояние = СостоянияТестов.Сломан Тогда
		Статус = "broken";
	ИначеЕсли Состояние = СостоянияТестов.НеизвестнаяОшибка Тогда
		Статус = "failed";
	КонецЕсли;	
	
	Возврат Статус;

КонецФункции
// } Helpers
