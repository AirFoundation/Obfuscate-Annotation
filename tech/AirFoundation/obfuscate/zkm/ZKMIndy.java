package tech.AirFoundation.obfuscate.zkm;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
/**
 * @author Yuxing
 * @author github.com/AirFoundation
 * @apiNote 感谢你找我混淆，请你将需要使用invokedynamic混淆的部分代码打上这个注解，可以是一个类也可以是一个方法。
 */
@Retention(RetentionPolicy.CLASS)
@Target({ElementType.METHOD, ElementType.TYPE})
public @interface ZKMIndy {
}
