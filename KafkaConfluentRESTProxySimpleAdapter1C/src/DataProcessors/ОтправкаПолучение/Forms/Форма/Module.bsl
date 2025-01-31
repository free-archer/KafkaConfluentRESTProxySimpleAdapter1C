&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ПустаяСтрока(Адрес) Тогда
		Адрес = "localhost:8082";
	КонецЕсли;

	Если ПустаяСтрока(Топик) Тогда
		Топик = "1c.topic";
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура Отправить(Команда)
	ОтправитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ОтправитьНаСервере()
	СоединениеКафка = Кафка.НовоеОписаниеСоединения(Адрес, "json");
	Отправитель = Кафка.НовыйОтправитель(СоединениеКафка);
	Кафка.ДобавитьСообщение(Отправитель, Текст, Топик);
	Кафка.ОтправитьСообщения(Отправитель);	
	
	Если СоединениеКафка.Свойство("РезультатСоединения") И СоединениеКафка.РезультатСоединения.Свойство("ИсторияОпераций") Тогда
		Ответ = СоединениеКафка.РезультатСоединения.ИсторияОпераций[СоединениеКафка.РезультатСоединения.ИсторияОпераций.Количество()-1]
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПримерОтправкиHTTP(Команда)
	ПримерОтправкиHTTPНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПримерОтправкиHTTPНаСервере()
	//Пример без использования модуля "Кафка"
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/vnd.kafka.json.v2+json");
	Заголовки.Вставить("Accept", "*/*");
	
	HTTPСоединение = Новый HTTPСоединение("localhost", 8082);
	HTTPЗапрос = Новый HTTPЗапрос("/topics/1c.topic", Заголовки);
	
	Сообщение = Новый Структура("value", Текст);
	
	МассивЗначений = Новый Массив;
	МассивЗначений.Добавить(Сообщение);
	
	Запись = Новый Структура;
	Запись.Вставить("records", МассивЗначений);
	
	JSONТекст = КоннекторHTTP.ОбъектВJson(Запись);
	
	HTTPЗапрос.УстановитьТелоИзСтроки(JSONТекст);
	
	Результат = HTTPСоединение.ВызватьHTTPМетод("POST", HTTPЗапрос);
	
	Ответ = Результат.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8);
КонецПроцедуры

&НаКлиенте
Процедура Получить(Команда)
	ПолучитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПолучитьНаСервере()
	Ответ = "";
	
	СоединениеКафка = Кафка.НовоеОписаниеСоединения(Адрес, "json");
	Подписчик = Кафка.НовыйПодписчик(СоединениеКафка, "ConsumerGroup1C", , Истина, 100);

	Кафка.ЗарегистрироватьПодписчика(Подписчик);
	Кафка.Подписаться(Подписчик, Топик);
	Сообщения = Кафка.ПолучитьСообщения(Подписчик);
	Для Каждого Сообщение Из Сообщения Цикл
		Ответ = Ответ+Сообщение.Получить("value")+Символы.ПС;
	КонецЦикла;

	Кафка.УдалитьПодисчика(Подписчик);
КонецПроцедуры