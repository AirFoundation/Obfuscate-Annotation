package tech.AirFoundation.obfuscate.jnic;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * @author github.com/AirFoundation
 * @apiNote Annotation that allows to include method or class to native obfuscation
 * @apiNote 感谢你信任我找我混淆，请将你认为重要的module/utils/主类等打上这个注解以使用jnic的native混淆
 */
@Retention(RetentionPolicy.CLASS)
@Target({ElementType.METHOD, ElementType.TYPE})
public @interface JNICInclude {
}