# Практическая работа №6
## Тема: Создание API при помощи пакета Conduit.
### Цель работы: необходимо реализовать API при помощи пакета Conduit. 

### Ход работы:
Для работы с API, необходимо было поставить библиотеки: conduit и jaguar_jwt.
Conduit использует анализ структуры классов для реализации ORM.
Jaguar_jwt это JSON объект, который определен в открытом стандарте RFC 7519. Он считается одним из безопасных способов передачи информации между двумя участниками. Для его создания необходимо определить заголовок (header) с общей информацией по токену, полезные данные (payload), такие как id пользователя, его роль и т.д. и подписи (signature).
Модели:
Для работы с БД, в программе прописываются модели, которые хранят в себе поля с их ограничениями.
Модель «Категория» имеет поля: наименование и заметка.

 ![image](https://user-images.githubusercontent.com/94557992/219962037-c0f97cb7-3393-4879-b77a-d0093fd52d65.png)

Рисунок 19 – Модель «Категория»
Модель «Заметка» имеет поля: название, контент, дата создания, удаление, автор и категория.
 
 ![image](https://user-images.githubusercontent.com/94557992/219962072-adc9347a-90ae-47e9-9155-3a12acf36c44.png)
 
Рисунок 20 – Модель «Заметка»
Модель «История» имеет поля: дата действия и действие.

![image](https://user-images.githubusercontent.com/94557992/219962107-ce5f4be5-36da-4fbe-9417-2957382fc193.png)

Рисунок 21 – Модель «История»
Модель «Пользователь» имеет поля: логин, пароль, почта, доступный токен, обновленный токен, соль, хешированный пароль и заметки.

![image](https://user-images.githubusercontent.com/94557992/219962116-fa3918fb-12ae-4de2-9bd3-b1f7d14c7b15.png)

Рисунок 22 – Модель «Пользователь»
Конфигурационные файлы:
В данном файле прописываются данные базы данных: наименование, пароль, хост, порт и имя БД.

![image](https://user-images.githubusercontent.com/94557992/219962133-ba47b392-a575-407d-b663-e621bb104726.png)

Рисунок 23 – Database
В данном файле прописываются исключения и ответы между приложением и БД.

![image](https://user-images.githubusercontent.com/94557992/219962142-f35de792-1d86-4415-a8ff-4f65f4761c95.png)

Рисунок 24 – AppResponse
В данном файле прописывается взаимосвязь между токеном и пользователем.

![image](https://user-images.githubusercontent.com/94557992/219962149-fae8268a-fbcb-46fb-b451-8bb83199be61.png)

Рисунок 25 – AppUtils
В данном файле прописываются маршруты и инициализируется БД.

![image](https://user-images.githubusercontent.com/94557992/219962158-030b6674-3cbd-42ac-86db-4c20722d012d.png)

Рисунок 26 – AppService
Результат работы программы:

![image](https://user-images.githubusercontent.com/94557992/219962167-dccb6488-1e6c-4c3f-bc59-150dd4d59a56.png)

Рисунок 27 – Регистрация пользователя

![image](https://user-images.githubusercontent.com/94557992/219962175-25bed6aa-208c-49fd-a651-b3f2c528a4ae.png)

Рисунок 28 – Авторизация пользователя

![image](https://user-images.githubusercontent.com/94557992/219962181-2b7e07f3-7ed4-44a0-9261-5b12b03b42cf.png)

Рисунок 29 – Обновление token’а

![image](https://user-images.githubusercontent.com/94557992/219962185-aab5fd3a-46f3-4c5d-9a8a-d09946b98242.png)

Рисунок 30 – Получение данных

![image](https://user-images.githubusercontent.com/94557992/219962189-0d5b2af9-456d-42b4-9504-a16ec9f7431b.png)

Рисунок 31 – Изменение данных

![image](https://user-images.githubusercontent.com/94557992/219962198-c67d98e7-c9b4-4406-ad18-20f284787c88.png)

Рисунок 32 – Изменение пароля

![image](https://user-images.githubusercontent.com/94557992/219962224-7abc7f51-9d37-4d28-a939-966b380c87c8.png)

Рисунок 33 – Создание категории

![image](https://user-images.githubusercontent.com/94557992/219962226-c2a31a8e-7824-40e0-b0e5-f25fe7996a0b.png)

Рисунок 34 – Вывод категорий

![image](https://user-images.githubusercontent.com/94557992/219962229-c16dfc47-ad5a-4700-8543-11a9776cb772.png)

Рисунок 35 – Изменение категории

![image](https://user-images.githubusercontent.com/94557992/219962232-3ff444f6-e150-4d84-9025-5aeb02fa3d10.png)

Рисунок 36 – Удаление категории

![image](https://user-images.githubusercontent.com/94557992/219962239-13800d7b-4f6c-476c-b73c-6ffcdadfcc77.png)

Рисунок 37 – Создание заметки

![image](https://user-images.githubusercontent.com/94557992/219962246-6e552ec5-6c4c-4857-96ab-fa261b32b768.png)

Рисунок 38 – Вывод заметок

![image](https://user-images.githubusercontent.com/94557992/219962250-bc8e2ac3-8aa1-49a6-b050-a9ef7dbe20c5.png)

Рисунок 39 – Вывод заметок с пагинацией

![image](https://user-images.githubusercontent.com/94557992/219962256-b6a499ac-849b-438e-b4fb-5d992a45e196.png)

Рисунок 40 – Изменение заметки
 
![image](https://user-images.githubusercontent.com/94557992/219962300-2e1ba1b5-3002-46ff-b39f-5118c807b71e.png)
 
Рисунок 41 – Удаление заметки на логическом уровне

![image](https://user-images.githubusercontent.com/94557992/219962304-42fce747-de92-4f29-a857-ec8787331782.png)

Рисунок 42 – Проверка удаления заметки на логическом уровне

![image](https://user-images.githubusercontent.com/94557992/219962307-ccd18995-27d8-432b-b198-61dec3ace4c1.png)

Рисунок 43 – Проверка удаления заметки

![image](https://user-images.githubusercontent.com/94557992/219962318-67242b01-8ca3-46e2-9d38-e80e3e8671ab.png)

Рисунок 44 – Физическое удаление заметки

![image](https://user-images.githubusercontent.com/94557992/219962320-16c50dda-1762-44c3-bb61-5e364457708d.png)

Рисунок 45 – Проверка физического удаления

![image](https://user-images.githubusercontent.com/94557992/219962325-888a05e5-9791-4c9b-b2c8-75f9250c4a0a.png)

Рисунок 46 – Восстановление данных

![image](https://user-images.githubusercontent.com/94557992/219962328-92d0459a-293e-4368-a249-5e88c17a8ccd.png)

Рисунок 47 – Проверка восстановленных данных

### Вывод: в ходе работы реализовала API при помощи пакета Conduit.
