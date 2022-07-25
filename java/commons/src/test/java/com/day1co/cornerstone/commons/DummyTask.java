package com.day1co.cornerstone.commons;

/**
 * 테스트용 타스크.
 *
 * 태스크를 실행하면 전달한 메시지가 속성에 설정된다.
 */
public class DummyTask implements Task<String> {
    public String message;

    @Override
    public Class<String> getMessageClass() {
        return String.class;
    }

    @Override
    public void execute(String message) {
        this.message = message;
    }
}
