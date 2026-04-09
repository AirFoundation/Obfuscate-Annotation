package tech.AirFoundation.obfuscate.jnic;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
/**
 * @author github.com/AirFoundation
 * @apiNote Annotation that allows to exclude method or class to native obfuscation
 * 感谢你信任我找我混淆，请将你认为已经打上@JNICInclude但是不是很重要的方法打上这个注解以排除jnic的native混淆
 */
@Retention(RetentionPolicy.CLASS)
@Target({ElementType.METHOD, ElementType.TYPE})
public @interface JNICExclude {
}