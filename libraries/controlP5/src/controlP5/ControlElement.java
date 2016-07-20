package controlP5;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Used for automated controller creation using annotations. Very much inspired by Karsten Schmidt's
 * (toxi) cp5magic
 * 
 * @example use/ControlP5annotation
 */
@Retention( RetentionPolicy.RUNTIME )
public @interface ControlElement {

	String[] properties() default { };

	String label() default "";

	int x() default -1;

	int y() default -1;

}
