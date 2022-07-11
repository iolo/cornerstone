export interface Task<T> {
  execute(message: T): Promise<void>;
}
