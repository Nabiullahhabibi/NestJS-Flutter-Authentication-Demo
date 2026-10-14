import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable, tap } from 'rxjs';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const started = Date.now(); const req = context.switchToHttp().getRequest();
    return next.handle().pipe(tap(() => console.log(`[HTTP] ${req.method} ${req.originalUrl} ${Date.now() - started}ms`)));
  }
}
