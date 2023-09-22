#!/bin/sh

# Prevents processing-java from stealing focus, see:
# https://github.com/processing/processing/issues/3996.
OPTION_FOR_HEADLESS_RUN=""
for ARG in "$@"
do
    if [ "$ARG" = "--build" ]; then
        OPTION_FOR_HEADLESS_RUN="-Djava.awt.headless=true"
    fi
done

cd "/Applications/Processing.app/Contents/Java" && /Applications/Processing.app/Contents/PlugIns/jdk-17.0.6+10/Contents/Home/bin/java -Djna.nosys=true $OPTION_FOR_HEADLESS_RUN -cp "ant.jar:ant-launcher.jar:core.jar:jna.jar:flatlaf.jar:pde.jar:jna-platform.jar:core/library/jogl-all.jar:core/library/gluegen-rt.jar:core/library/core.jar:modes/java/mode/com.ibm.icu.jar:modes/java/mode/org.eclipse.core.contenttype.jar:modes/java/mode/org.eclipse.core.jobs.jar:modes/java/mode/org.eclipse.lsp4j.jsonrpc.jar:modes/java/mode/org.eclipse.text.jar:modes/java/mode/org.eclipse.jdt.compiler.apt.jar:modes/java/mode/antlr-4.7.2-complete.jar:modes/java/mode/org.eclipse.core.runtime.jar:modes/java/mode/jdtCompilerAdapter.jar:modes/java/mode/classpath-explorer-1.0.jar:modes/java/mode/org.eclipse.equinox.common.jar:modes/java/mode/gson.jar:modes/java/mode/org.eclipse.lsp4j.jar:modes/java/mode/org.netbeans.swing.outline.jar:modes/java/mode/org.eclipse.osgi.jar:modes/java/mode/JavaMode.jar:modes/java/mode/jsoup-1.7.1.jar:modes/java/mode/antlr.jar:modes/java/mode/org.eclipse.core.resources.jar:modes/java/mode/org.eclipse.jdt.core.jar:modes/java/mode/org.eclipse.equinox.preferences.jar" processing.mode.java.Commander "$@"
