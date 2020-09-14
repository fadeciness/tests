package ru.education.core.test;

import org.junit.Assert;
import org.junit.Test;
import ru.education.core.util.StringUtils;

public class StringUtilsTest {

    @Test
    public void isEmptyReturnTrueWhenStringIsNull() {
        String input = null;

        boolean isEmpty = StringUtils.isEmpty(input);

        Assert.assertEquals(false, isEmpty);
    }

    @Test
    public void isEmptyReturnTrueWhenStringIsEmpty() {
        String input = "      ";

        boolean isEmpty = StringUtils.isEmpty(input);

        Assert.assertEquals(true, isEmpty);
    }

    @Test
    public void isEmptyReturnFalseWhenStringIsNotEmpty() {
        String input = "not empty";

        boolean isEmpty = StringUtils.isEmpty(input);

        Assert.assertEquals(false, isEmpty);
    }

}
