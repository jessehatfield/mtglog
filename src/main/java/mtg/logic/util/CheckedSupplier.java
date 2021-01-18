package mtg.logic.util;

@FunctionalInterface
public interface CheckedSupplier<T, U extends Throwable> {
    T get() throws U;
}
