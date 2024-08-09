USE roombee;

CREATE TABLE todolist (
    userId varchar(128) not null, 
    todoTitle varchar(128) not null, 
    todoContent varchar(128) not null, 
    todoPriority varchar(128) not null, 
    todoCategory varchar(128) not null, 
    todoStatus BOOL
);


