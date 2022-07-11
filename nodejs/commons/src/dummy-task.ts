import type { Task } from './task';

export class DummyTask implements Task<string> {
  public message = '';

  async execute(message: string): Promise<void> {
    console.log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    console.log('>>', new Date().toISOString());
    console.log('>>', message);
    console.log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    this.message = message;
  }
}
