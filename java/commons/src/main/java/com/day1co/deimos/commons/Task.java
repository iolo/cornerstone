package com.day1co.cornerstone.commons;

public interface Task<T> {
    Class<T> getMessageClass();

    void execute(T message);
}
