package mg.itu.myframework.util;

import io.github.classgraph.ClassGraph;
import io.github.classgraph.ClassInfo;
import io.github.classgraph.ScanResult;

import java.util.*;
import java.lang.annotation.Annotation;

public class Util {

    public static List<Class<?>> getClassesAnnotation(List<String> packageNames, Class<? extends Annotation> annotation) {
        List<Class<?>> classes = new ArrayList<>();
        for (String packageName : packageNames) {
            classes.addAll(getClasses(packageName));
        }
        List<Class<?>> result = new ArrayList<>();
        for (Class<?> clazz : classes) {
            if (clazz.isAnnotationPresent(annotation)) {
                result.add(clazz);
            }
        }
        return result;
    }



    public static List<Class<?>> getClasses(String packageName) {
        List<Class<?>> classes = new ArrayList<>();

        try (ScanResult scan = new ClassGraph()
                .enableClassInfo()
                .scan()) {

            for (ClassInfo classInfo : scan.getAllClasses()) {
                try {
                    if (classInfo.getPackageName().equals(packageName)) {
                        classes.add(classInfo.loadClass());
                    }
                } catch (Throwable e) {
                }
            }
        }

        return classes;
    }

}